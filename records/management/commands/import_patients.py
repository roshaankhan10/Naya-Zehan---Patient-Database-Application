import csv
from django.core.management.base import BaseCommand
from records.models import Patient
from datetime import datetime

class Command(BaseCommand):
    help = 'Import patient data from PATREC.csv'

    def handle(self, *args, **kwargs):
        with open('PATREC.csv', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            count = 0
            for row in reader:
                if not row['H_ID_NO'] or not row['NAME']:
                    continue  # skip invalid rows

                try:
                    patient = Patient(
                        hospital_id=row['H_ID_NO'],
                        name=row['NAME'],
                        father_name=row['FNAME'] or None,
                        surname=row['SURNAME'] or None,
                        nic=row['N_I_C_NO'] or None,
                        dob=datetime.strptime(row['DATE_BIR'], '%Y-%m-%d').date() if row['DATE_BIR'] else None,
                        age=int(row['AGE']) if row['AGE'] else None,
                        sex=row['SEX'] or None,
                        marital_status=row['MARITAL_S'] or None,
                        religion=row['RELIGION'] or None,
                        education=row['LEVEL_ED'] or None,
                        occupation=row['OCCUPATION'] or None,
                        address=row['ADDRESS'] or None
                    )
                    patient.save()
                    count += 1
                except Exception as e:
                    print(f"Failed row: {row['H_ID_NO']} → {e}")

            print(f"✅ Imported {count} patients successfully.")
