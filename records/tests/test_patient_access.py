"""Role behaviour on Patient records, asserted through the HTTP API."""
from records.models import Patient
from records.tests.support import RoleTestCase


class PatientAccessTest(RoleTestCase):
    """A User may read every Patient record; only an Admin may create one."""

    NEW_RECORD = {'hospital_id': 'NZ-TEST-1', 'name': 'Test Record'}

    @classmethod
    def setUpTestData(cls):
        super().setUpTestData()
        cls.existing = Patient.objects.create(hospital_id='H-1', name='Existing Record')

    def test_unauthenticated_request_is_rejected(self):
        response = self.client.get('/api/patients/')
        self.assertEqual(response.status_code, 401)

    def test_user_may_read_patient_records(self):
        self.login_as(self.user)
        response = self.client.get('/api/patients/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            [row['hospital_id'] for row in response.data['results']], ['H-1'],
        )

    def test_user_may_not_create_a_patient_record(self):
        self.login_as(self.user)
        response = self.client.post('/api/patients/', self.NEW_RECORD, format='json')
        self.assertEqual(response.status_code, 403)
        self.assertEqual(Patient.objects.count(), 1)

    def test_admin_may_create_a_patient_record(self):
        self.login_as(self.admin)
        response = self.client.post('/api/patients/', self.NEW_RECORD, format='json')
        self.assertEqual(response.status_code, 201)
        self.assertTrue(Patient.objects.filter(hospital_id='NZ-TEST-1').exists())

    def test_superuser_may_create_a_patient_record(self):
        self.login_as(self.superuser)
        response = self.client.post('/api/patients/', self.NEW_RECORD, format='json')
        self.assertEqual(response.status_code, 201)

    def test_clearing_credentials_leaves_the_client_unauthenticated(self):
        self.login_as(self.admin)
        self.clear_credentials()
        self.assertEqual(self.client.get('/api/patients/').status_code, 401)
