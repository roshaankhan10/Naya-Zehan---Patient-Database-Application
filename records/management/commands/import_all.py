"""
Place this file at:
  records/management/commands/import_all.py

Make sure this structure exists:
  records/
    management/
      __init__.py
      commands/
        __init__.py
        import_all.py

Run with:
  python manage.py import_all
"""

import os
import csv
import pandas as pd
from django.core.management.base import BaseCommand
from django.db import transaction
from records.models import Patient, Admission
from dbfread import DBF, FieldParser


# ── Lax DBF date parser (handles corrupt date fields) ─────────────────────────
class LaxParser(FieldParser):
    def parseD(self, field, data):
        try:
            return super().parseD(field, data)
        except Exception:
            return None


# ── Field cleaners ─────────────────────────────────────────────────────────────
def clean(val):
    """Strip and return None if empty."""
    if val is None:
        return None
    s = str(val).strip()
    return s if s and s.lower() not in ('nan', 'none', '') else None


def clean_age(val):
    """Keep age as-is string e.g. '28.Y'."""
    return clean(val)


def clean_sex(val):
    s = clean(val)
    if not s:
        return None
    return {'M': 'Male', 'F': 'Female'}.get(s.upper(), s)


def clean_marital(val):
    s = clean(val)
    if not s:
        return None
    return {'S': 'Single', 'M': 'Married', 'D': 'Divorced', 'W': 'Widowed'}.get(s.upper(), s)


def clean_date(val):
    """Return a date object or None."""
    if val is None:
        return None
    if hasattr(val, 'date'):
        return val.date()
    if hasattr(val, 'year'):
        return val
    s = str(val).strip()
    if not s or s.lower() in ('nan', 'none', 'nat'):
        return None
    for fmt in ('%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y'):
        try:
            from datetime import datetime
            return datetime.strptime(s.split(' ')[0], fmt).date()
        except ValueError:
            continue
    return None


# ── Row → Patient ──────────────────────────────────────────────────────────────
def row_to_patient_dict(record):
    return dict(
        hospital_id=clean(record.get('H_ID_NO')),
        name=clean(record.get('NAME')),
        father_name=clean(record.get('FNAME')),
        surname=clean(record.get('SURNAME')),
        nic=clean(record.get('N_I_C_NO')),
        dob=clean_date(record.get('DATE_BIR')),
        age=clean_age(record.get('AGE')),
        sex=clean_sex(record.get('SEX')),
        marital_status=clean_marital(record.get('MARITAL_S')),
        religion=clean(record.get('RELIGION')),
        education=clean(record.get('LEVEL_ED')),
        occupation=clean(record.get('OCCUPATION')),
        address=clean(record.get('ADDRESS')),
    )


# ── Row → Admission ────────────────────────────────────────────────────────────
def row_to_admission_dict(record):
    return dict(
        hospital_id_ref=clean(record.get('H_ID_NO')),
        date_of_admission=clean_date(record.get('DOA')),
        ward_no=clean(record.get('WARD_NO')),
        ref_source=clean(record.get('REF_SOURCE')),
        is_current=bool(record.get('EXIST', False)),
    )


# ── Main command ───────────────────────────────────────────────────────────────
class Command(BaseCommand):
    help = 'Import all patients (PATREC2.csv) and admissions (INDOOR1.DBF) into Supabase'

    def add_arguments(self, parser):
        parser.add_argument(
            '--patients',
            type=str,
            default='PATREC2.csv',
            help='Path to patient CSV file (default: PATREC2.csv)',
        )
        parser.add_argument(
            '--admissions',
            type=str,
            default='INDOOR1.DBF',
            help='Path to admissions DBF file (default: INDOOR1.DBF)',
        )
        parser.add_argument(
            '--batch',
            type=int,
            default=500,
            help='Batch size for bulk insert (default: 500)',
        )
        parser.add_argument(
            '--skip-patients',
            action='store_true',
            help='Skip patient import, only import admissions',
        )
        parser.add_argument(
            '--skip-admissions',
            action='store_true',
            help='Skip admissions import, only import patients',
        )

    def handle(self, *args, **options):
        batch_size = options['batch']

        # ── 1. Import Patients ─────────────────────────────────────────────────
        if not options['skip_patients']:
            patient_file = options['patients']
            if not os.path.exists(patient_file):
                self.stderr.write(self.style.ERROR(f'Patient file not found: {patient_file}'))
                return

            self.stdout.write(self.style.MIGRATE_HEADING(f'\n── Importing patients from {patient_file} ──'))

            # Read CSV in chunks to handle 123K rows without memory issues
            chunk_size = 2000
            total_created = 0
            total_skipped = 0
            chunk_num = 0

            for chunk in pd.read_csv(patient_file, chunksize=chunk_size,
                                     dtype=str, keep_default_na=False, na_values=['']):
                chunk_num += 1
                batch = []

                for _, row in chunk.iterrows():
                    record = row.to_dict()
                    # Skip fully empty rows
                    if not any(v.strip() for v in record.values() if isinstance(v, str)):
                        total_skipped += 1
                        continue

                    patient_dict = row_to_patient_dict(record)

                    # Skip if no name at all
                    if not patient_dict['name']:
                        total_skipped += 1
                        continue

                    batch.append(Patient(**patient_dict))

                if batch:
                    with transaction.atomic():
                        Patient.objects.bulk_create(batch, batch_size=batch_size)
                    total_created += len(batch)
                    self.stdout.write(f'  Chunk {chunk_num}: inserted {len(batch)} patients '
                                      f'(total so far: {total_created})')

            self.stdout.write(self.style.SUCCESS(
                f'  ✓ Patients done: {total_created} imported, {total_skipped} skipped\n'
            ))

        # ── 2. Import Admissions ───────────────────────────────────────────────
        if not options['skip_admissions']:
            admission_file = options['admissions']
            if not os.path.exists(admission_file):
                self.stderr.write(self.style.ERROR(f'Admissions file not found: {admission_file}'))
                return

            self.stdout.write(self.style.MIGRATE_HEADING(f'── Importing admissions from {admission_file} ──'))

            table = DBF(admission_file, ignore_missing_memofile=True, parserclass=LaxParser)
            records = [dict(r) for r in table]
            self.stdout.write(f'  Found {len(records)} admission records')

            # Build a lookup: hospital_id → Patient (for linking FKs)
            self.stdout.write('  Building patient lookup table...')
            patient_lookup = {}
            for p in Patient.objects.filter(hospital_id__isnull=False).values('id', 'hospital_id'):
                patient_lookup[p['hospital_id']] = p['id']
            self.stdout.write(f'  Lookup built: {len(patient_lookup)} patients with H_ID_NO')

            batch = []
            linked = 0
            unlinked = 0

            for record in records:
                adm_dict = row_to_admission_dict(record)
                h_id = adm_dict['hospital_id_ref']
                patient_id = patient_lookup.get(h_id) if h_id else None

                admission = Admission(
                    patient_id=patient_id,
                    hospital_id_ref=adm_dict['hospital_id_ref'],
                    date_of_admission=adm_dict['date_of_admission'],
                    ward_no=adm_dict['ward_no'],
                    ref_source=adm_dict['ref_source'],
                    is_current=adm_dict['is_current'],
                )
                batch.append(admission)

                if patient_id:
                    linked += 1
                else:
                    unlinked += 1

                if len(batch) >= batch_size:
                    with transaction.atomic():
                        Admission.objects.bulk_create(batch)
                    self.stdout.write(f'  Inserted batch of {len(batch)} admissions...')
                    batch = []

            # Insert remaining
            if batch:
                with transaction.atomic():
                    Admission.objects.bulk_create(batch)
                self.stdout.write(f'  Inserted final batch of {len(batch)} admissions')

            self.stdout.write(self.style.SUCCESS(
                f'  ✓ Admissions done: {len(records)} imported '
                f'({linked} linked to patients, {unlinked} unlinked)\n'
            ))

        self.stdout.write(self.style.SUCCESS('══ All done! Check Supabase Table Editor to verify. ══'))