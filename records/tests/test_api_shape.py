"""The fields the API hands back, pinned.

Ticket 02 removes decoys behind the serializers — a duplicated declaration and an
unused model field. Nothing users see may change, so the response shape is asserted
here explicitly rather than left to be noticed in the Flutter client.
"""
from datetime import date

from records.models import Admission, Patient
from records.tests.support import RoleTestCase


PATIENT_FIELDS = {
    'id', 'hospital_id', 'name', 'father_name', 'surname', 'nic', 'dob', 'age',
    'sex', 'marital_status', 'religion', 'education', 'occupation', 'address',
}

ADMISSION_FIELDS = {
    'id', 'patient', 'patient_hospital_id', 'patient_name', 'date_of_admission',
    'ward_no', 'ref_source', 'is_current',
}


class ApiShapeTest(RoleTestCase):
    """Patient and Admission responses carry exactly these fields."""

    @classmethod
    def setUpTestData(cls):
        super().setUpTestData()
        cls.patient = Patient.objects.create(hospital_id='H-1', name='Existing Record')
        cls.admission = Admission.objects.create(
            patient=cls.patient,
            date_of_admission=date(2020, 1, 1),
            ward_no='3',
            ref_source='Outpatient',
        )

    def test_patient_list_fields(self):
        self.login_as(self.user)
        response = self.client.get('/api/patients/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(set(response.data['results'][0]), PATIENT_FIELDS)

    def test_patient_detail_fields(self):
        self.login_as(self.user)
        response = self.client.get(f'/api/patients/{self.patient.id}/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(set(response.data), PATIENT_FIELDS)

    def test_admission_list_fields(self):
        self.login_as(self.user)
        response = self.client.get('/api/admissions/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(set(response.data['results'][0]), ADMISSION_FIELDS)

    def test_admission_carries_the_patient_it_points_at(self):
        self.login_as(self.user)
        row = self.client.get('/api/admissions/').data['results'][0]
        self.assertEqual(row['patient'], self.patient.id)
        self.assertEqual(row['patient_hospital_id'], 'H-1')
        self.assertEqual(row['patient_name'], 'Existing Record')

    def test_admin_may_create_an_admission(self):
        self.login_as(self.admin)
        response = self.client.post(
            '/api/admissions/',
            {
                'patient': self.patient.id,
                'date_of_admission': '2021-06-01',
                'ward_no': '4',
                'ref_source': 'Self',
                'is_current': True,
            },
            format='json',
        )
        self.assertEqual(response.status_code, 201, response.data)
        self.assertEqual(set(response.data), ADMISSION_FIELDS)
        self.assertEqual(Admission.objects.filter(ward_no='4').count(), 1)
