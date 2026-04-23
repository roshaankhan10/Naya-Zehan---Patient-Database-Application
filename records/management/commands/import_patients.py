# records/management/commands/import_patients.py

import csv
import sys
from django.core.management.base import BaseCommand, CommandError
from records.models import Patient
from datetime import datetime


class Command(BaseCommand):
    help = 'Import patient data from a CSV file (converted from PATREC.DBF)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--file',
            type=str,
            default='PATREC2.csv',
            help='Path to the patient CSV file (default: PATREC2.csv)',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Parse and validate without saving to database',
        )

    def handle(self, *args, **options):
        filepath = options['file']
        dry_run = options['dry_run']

        if dry_run:
            self.stdout.write(self.style.WARNING('DRY RUN — no data will be saved.\n'))

        try:
            with open(filepath, newline='', encoding='utf-8') as csvfile:
                reader = csv.DictReader(csvfile)
                rows = list(reader)
        except FileNotFoundError:
            raise CommandError(f'File not found: {filepath}')
        except Exception as e:
            raise CommandError(f'Error reading file: {e}')

        total = len(rows)
        imported = 0
        skipped = 0
        errors = []

        self.stdout.write(f'Processing {total} rows from {filepath}...\n')

        for i, row in enumerate(rows, start=1):
            h_id = row.get('H_ID_NO', '').strip()
            name = row.get('NAME', '').strip()

            # Skip rows without essential fields
            if not h_id or not name:
                skipped += 1
                continue

            try:
                # Parse date of birth
                dob = None
                dob_str = row.get('DATE_BIR', '').strip()
                if dob_str:
                    for fmt in ('%Y-%m-%d', '%Y-%m-%d %H:%M:%S', '%d/%m/%Y'):
                        try:
                            dob = datetime.strptime(dob_str, fmt).date()
                            break
                        except ValueError:
                            continue

                # Parse age (handles formats like "28.Y", "28Y", "28")
                age = None
                age_str = row.get('AGE', '').strip()
                if age_str:
                    cleaned = age_str.split('.')[0].split()[0].replace('Y', '').replace('y', '')
                    if cleaned.isdigit():
                        age = int(cleaned)

                defaults = {
                    'name': name,
                    'father_name': row.get('FNAME', '').strip() or None,
                    'surname': row.get('SURNAME', '').strip() or None,
                    'nic': row.get('N_I_C_NO', '').strip() or None,
                    'dob': dob,
                    'age': age,
                    'sex': row.get('SEX', '').strip() or None,
                    'marital_status': row.get('MARITAL_S', '').strip() or None,
                    'religion': row.get('RELIGION', '').strip() or None,
                    'education': row.get('LEVEL_ED', '').strip() or None,
                    'occupation': row.get('OCCUPATION', '').strip() or None,
                    'address': row.get('ADDRESS', '').strip() or None,
                }

                if not dry_run:
                    Patient.objects.update_or_create(
                        hospital_id=h_id,
                        defaults=defaults,
                    )

                imported += 1

            except Exception as e:
                errors.append(f'Row {i} (ID: {h_id}): {e}')

            # Progress reporting every 1000 rows
            if i % 1000 == 0:
                self.stdout.write(f'  Progress: {i}/{total} rows processed...\n')

        # Summary
        self.stdout.write('\n' + '=' * 50 + '\n')
        action = 'validated' if dry_run else 'imported'
        self.stdout.write(self.style.SUCCESS(
            f'✅ {imported} patients {action} successfully.\n'
        ))
        if skipped:
            self.stdout.write(self.style.WARNING(
                f'⚠️  {skipped} rows skipped (missing ID or name).\n'
            ))
        if errors:
            self.stdout.write(self.style.ERROR(
                f'❌ {len(errors)} errors:\n'
            ))
            for err in errors[:20]:  # Show first 20 errors
                self.stdout.write(f'   {err}\n')
            if len(errors) > 20:
                self.stdout.write(f'   ... and {len(errors) - 20} more.\n')
