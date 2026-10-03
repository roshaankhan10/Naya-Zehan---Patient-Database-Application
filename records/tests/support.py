"""Shared fixtures for the test suite.

The roles are the ones named in `CONTEXT.md`: an **Admin** (an account with
`is_staff` or `is_superuser`), and a **User** (an account with neither flag).
Both flags are covered separately because `IsAdminOrReadOnly` accepts either.
"""
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APITestCase

PASSWORD = 'harness-pw-9f3a'


class RoleTestCase(APITestCase):
    """Base case giving every test an account of each role and a login helper.

    Subclasses get `self.admin`, `self.superuser` and `self.user`, and
    authenticate with `self.login_as(...)`, which goes through the real token
    endpoint so tests exercise the same path the mobile app does.
    """

    @classmethod
    def setUpTestData(cls):
        super().setUpTestData()
        cls.admin = User.objects.create_user(
            username='harness_admin', password=PASSWORD, is_staff=True,
        )
        cls.superuser = User.objects.create_superuser(
            username='harness_superuser', password=PASSWORD, email='',
        )
        cls.user = User.objects.create_user(
            username='harness_user', password=PASSWORD,
        )

    def login_as(self, account):
        """Authenticate the test client as `account`."""
        response = self.client.post(
            reverse('token_obtain_pair'),
            {'username': account.username, 'password': PASSWORD},
            format='json',
        )
        self.assertEqual(
            response.status_code, 200,
            f'could not obtain a token for {account.username}: {response.content!r}',
        )
        token = response.data['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def clear_credentials(self):
        """Leave the test client unauthenticated.

        Not a logout: the token itself stays valid, this only stops the client
        sending it.
        """
        self.client.credentials()
