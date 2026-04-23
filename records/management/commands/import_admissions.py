# records/management/commands/import_admissions.py

import csv
from django.core.management.base import BaseCommand, CommandError
from records.models import Admission, Patient
from datetime import datetime


class Command(BaseCommand):
    help = 'Import admission records from a CSV file (converted from INDOOR1.DBF)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--file',
            type=str,
            default='INDOOR1.csv',
            help='Path to the admissions CSV file (default: INDOOR1.csv)',
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
        skipped_no_patient = 0
        errors = []

        self.stdout.write(f'Processing {total} admission rows from {filepath}...\n')

        for i, row in enumerate(rows, start=1):
            hospital_id = row.get('H_ID_NO', '').strip()
            if not hospital_id:
                errors.append(f'Row {i}: Missing hospital ID')
                continue

            try:
                # Parse admission date
                date_str = row.get('DOA', '').strip()
                date_of_admission = None
                if date_str:
                    for fmt in ('%Y-%m-%d', '%Y-%m-%d %H:%M:%S', '%d/%m/%Y'):
                        try:
                            date_of_admission = datetime.strptime(date_str, fmt).date()
                            break
                        except ValueError:
                            continue

                if date_of_admission is None:
                    errors.append(f'Row {i} (ID: {hospital_id}): Invalid date "{date_str}"')
                    continue

                ward_no = row.get('WARD_NO', '').strip()
                ref_source = row.get('REF_SOURCE', '').strip() or None
                exist_str = row.get('EXIST', '').strip().lower()
                is_current = exist_str in ('true', '1', 'yes')

                # Check patient exists
                try:
                    patient = Patient.objects.get(hospital_id=hospital_id)
                except Patient.DoesNotExist:
                    skipped_no_patient += 1
                    continue

                if not dry_run:
                    Admission.objects.create(
                        patient=patient,
                        date_of_admission=date_of_admission,
                        ward_no=ward_no,
                        ref_source=ref_source,
                        is_current=is_current,
                    )

                imported += 1

            except Exception as e:
                errors.append(f'Row {i} (ID: {hospital_id}): {e}')

            # Progress reporting
            if i % 1000 == 0:
                self.stdout.write(f'  Progress: {i}/{total} rows processed...\n')

        # Summary
        self.stdout.write('\n' + '=' * 50 + '\n')
        action = 'validated' if dry_run else 'imported'
        self.stdout.write(self.style.SUCCESS(
            f'✅ {imported} admissions {action} successfully.\n'
        ))
        if skipped_no_patient:
            self.stdout.write(self.style.WARNING(
                f'⚠️  {skipped_no_patient} rows skipped (patient not found in DB).\n'
            ))
        if errors:
            self.stdout.write(self.style.ERROR(
                f'❌ {len(errors)} errors:\n'
            ))
            for err in errors[:20]:
                self.stdout.write(f'   {err}\n')
            if len(errors) > 20:
                self.stdout.write(f'   ... and {len(errors) - 20} more.\n')
