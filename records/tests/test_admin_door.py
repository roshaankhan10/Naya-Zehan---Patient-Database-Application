"""Django's admin site is not a second door into patient records.

Ticket 03: the admin offered full create, edit and destroy over every Patient
record through session authentication, bypassing `IsAdminOrReadOnly` — and would
bypass the access log once that lands. It is gone from `INSTALLED_APPS` and from
the URL configuration; these tests hold it gone.

The routing assertions are the load-bearing ones: an unrouted path cannot serve a
login form to anybody, session or not. The HTTP-level check makes the same claim end
to end.
"""
from django.urls import NoReverseMatch, Resolver404, resolve, reverse

from records.tests.support import RoleTestCase

ADMIN_PATHS = [
    '/admin/',
    '/admin/login/',
    '/admin/records/patient/',
    '/admin/records/patient/1/change/',
]


class AdminDoorClosedTest(RoleTestCase):
    """Nothing under /admin/ is routed anywhere, for any role."""

    def test_no_admin_path_resolves_to_a_view(self):
        for path in ADMIN_PATHS:
            with self.subTest(path=path):
                with self.assertRaises(Resolver404):
                    resolve(path)

    def test_no_admin_url_is_registered(self):
        with self.assertRaises(NoReverseMatch):
            reverse('admin:index')

    def test_a_request_for_an_admin_path_is_a_404(self):
        for path in ADMIN_PATHS:
            with self.subTest(path=path):
                response = self.client.get(path)
                self.assertEqual(response.status_code, 404)
                self.assertNotIn(b'<form', response.content.lower())


class ApiStillWorksTest(RoleTestCase):
    """Closing the admin door left the API's own doors open."""

    def test_every_role_can_still_read_patient_records(self):
        for account in (self.user, self.admin, self.superuser):
            with self.subTest(account=account.username):
                self.login_as(account)
                self.assertEqual(self.client.get('/api/patients/').status_code, 200)
