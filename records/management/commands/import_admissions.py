import csv
from django.core.management.base import BaseCommand
from records.models import Admission, Patient
from datetime import datetime

class Command(BaseCommand):
    help = 'Import admission records from INDOOR1.csv'

    def handle(self, *args, **kwargs):
        with open('INDOOR1.csv', newline='', encoding='utf-8') as csvfile:
            reader = csv.reader(csvfile)
            next(reader, None)  # skip header
            count = 0
            for row in reader:
                try:
                    hospital_id = row[0].strip()
                    date_of_admission = datetime.strptime(row[5], '%Y-%m-%d').date() if row[5] else None
                    ward_no = row[6].strip() if row[6] else ''
                    ref_source = row[10].strip() if len(row) > 10 and row[10] else None
                    is_current = row[7].strip().lower() == 'true'

                    # patient = Patient.objects.get(hospital_id=hospital_id)
                    patient = Patient.objects.filter(hospital_id=hospital_id).first()
                    if patient is None:
                        print(f"Skipping: Patient ID {hospital_id} not found.")
                        continue
                    Admission.objects.create(
                        patient=patient,
                        date_of_admission=date_of_admission,
                        ward_no=ward_no,
                        ref_source=ref_source,
                        is_current=is_current
                    )
                    count += 1
                except Patient.DoesNotExist:
                    print(f"Skipping: Patient ID {hospital_id} not found.")
                except Exception as e:
                    print(f"Error importing row for {row[0]}: {e}")

            print(f"✅ Imported {count} admissions successfully.")
