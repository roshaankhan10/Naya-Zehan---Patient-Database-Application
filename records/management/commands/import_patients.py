# records/management/commands/import_patients.py

import csv
from django.core.management.base import BaseCommand
from records.models import Patient
from datetime import datetime

class Command(BaseCommand):
    help = 'Import patient data from patrec.csv'

    def handle(self, *args, **kwargs):
        with open('PATREC2.csv', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            count = 0
            for row in reader:
                h_id = row['H_ID_NO'].strip()
                name = row['NAME'].strip()

                if not h_id or not name:
                    continue

                try:
                    dob_str = row['DATE_BIR'].strip()
                    dob = None
                    if dob_str:
                        for fmt in ('%Y-%m-%d', '%Y-%m-%d %H:%M:%S'):
                            try:
                                dob = datetime.strptime(dob_str, fmt).date()
                                break
                            except ValueError:
                                continue

                    age_str = row['AGE'].strip().split()[0].replace('Y', '') if row['AGE'].strip() else ''
                    age = int(age_str) if age_str.isdigit() else None

                    patient, created = Patient.objects.update_or_create(
                        hospital_id=h_id,
                        defaults={
                            'name': name,
                            'father_name': row['FNAME'].strip() or None,
                            'surname': row['SURNAME'].strip() or None,
                            'nic': row['N_I_C_NO'].strip() or None,
                            'dob': dob,
                            'age': age,
                            'sex': row['SEX'].strip() or None,
                            'marital_status': row['MARITAL_S'].strip() or None,
                            'religion': row['RELIGION'].strip() or None,
                            'education': row['LEVEL_ED'].strip() or None,
                            'occupation': row['OCCUPATION'].strip() or None,
                            'address': row['ADDRESS'].strip() or None
                        }
                    )
                    count += 1
                except Exception as e:
                    print(f"❌ Failed row {h_id}: {e}")

            print(f"✅ Imported {count} patients successfully.")
