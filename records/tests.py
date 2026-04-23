from django.contrib.auth.models import User
from rest_framework.test import APITestCase
from rest_framework import status
from django.urls import reverse
from records.models import Patient, Admission
from datetime import date

class NayaZehanAPITests(APITestCase):
    
    def setUp(self):
        # 1. Provide an authenticated user for tests
        self.user = User.objects.create_user(username='test_admin', password='testpassword123')
        
        # 2. Add some mock patient data similar to legacy DBF records
        self.patient1 = Patient.objects.create(
            hospital_id='10001',
            name='Ali Khan',
            father_name='Ahmed Khan',
            surname='Baloch',
            age=45,
            sex='M'
        )
        self.patient2 = Patient.objects.create(
            hospital_id='10002',
            name='Fatima Imran',
            father_name='Imran Zafar',
            surname='Syed',
            age=32,
            sex='F'
        )
        
        # 3. Add a mock admission record
        self.admission = Admission.objects.create(
            patient=self.patient1,
            date_of_admission=date.today(),
            ward_no='7-B',
            ref_source='OPD',
            is_current=True
        )

    def get_auth_token(self):
        """Helper function to fetch the JWT access token by simulating login."""
        url = reverse('token_obtain_pair')
        response = self.client.post(url, {'username': 'test_admin', 'password': 'testpassword123'}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        return response.data['access']

    def test_authentication_required(self):
        """Test that the endpoints are protected and reject unauthenticated requests."""
        response = self.client.get('/api/patients/')
        # Should return 401 Unauthorized since no token is provided
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_patient_list_and_details(self):
        """Test fetching patient list and specific nested details via JWT."""
        token = self.get_auth_token()
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        # Test List endpoint
        list_response = self.client.get('/api/patients/')
        self.assertEqual(list_response.status_code, status.HTTP_200_OK)
        self.assertEqual(list_response.data['count'], 2) # Pagination count
        
        # Test Detail endpoint (should contain nested admission data)
        detail_response = self.client.get(f'/api/patients/{self.patient1.hospital_id}/')
        self.assertEqual(detail_response.status_code, status.HTTP_200_OK)
        self.assertEqual(detail_response.data['name'], 'Ali Khan')
        
        # Verify the custom PatientWithAdmissionsSerializer nested structure works
        self.assertTrue('admissions' in detail_response.data)
        self.assertEqual(len(detail_response.data['admissions']), 1)
        self.assertEqual(detail_response.data['admissions'][0]['ward_no'], '7-B')

    def test_multi_parameter_search(self):
        """Test the new search logic combining multiple fields."""
        token = self.get_auth_token()
        self.client.credentials(HTTP_AUTHORIZATION='Bearer ' + token)
        
        # 1. Search by Name (partial match)
        search_res = self.client.get('/api/patients/search/', {'name': 'Fatima'})
        self.assertEqual(search_res.status_code, status.HTTP_200_OK)
        self.assertEqual(search_res.data['count'], 1)
        self.assertEqual(search_res.data['results'][0]['hospital_id'], '10002')
        
        # 2. Search by Surname (case insensitive)
        search_res = self.client.get('/api/patients/search/', {'surname': 'baloch'})
        self.assertEqual(search_res.status_code, status.HTTP_200_OK)
        self.assertEqual(search_res.data['count'], 1)
        self.assertEqual(search_res.data['results'][0]['name'], 'Ali Khan')
        
        # 3. Empty Search (Should fail gracefully preventing database dumping)
        search_res = self.client.get('/api/patients/search/')
        self.assertEqual(search_res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(search_res.data['detail'], 'Provide at least one search parameter.')
