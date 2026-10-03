"""The deployed settings use names this version of Django still reads.

Django ignores a setting it doesn't recognise, without a warning. A renamed or removed
setting left in `backend/settings.py` therefore does nothing at all, and no other
test notices: `STATICFILES_STORAGE` going dead would quietly stop production serving
WhiteNoise's compressed static files.

These assertions read `backend.settings` itself rather than `django.conf.settings`,
because the latter fills in Django's own defaults for anything the module leaves out.
"""
from django.test import SimpleTestCase

import backend.settings


class NoRemovedSettingsTest(SimpleTestCase):
    REMOVED_SETTINGS = [
        'USE_L10N',                   # Django 5.0: localisation is always on
        'STATICFILES_STORAGE',        # Django 5.1: replaced by STORAGES
        'SECURE_BROWSER_XSS_FILTER',  # Django 4.0: X-XSS-Protection is gone
    ]

    def test_no_setting_django_no_longer_reads_is_set(self):
        for name in self.REMOVED_SETTINGS:
            with self.subTest(setting=name):
                self.assertFalse(hasattr(backend.settings, name))


class StaticFilesStorageTest(SimpleTestCase):
    def test_static_files_are_served_through_whitenoise_compression(self):
        self.assertEqual(
            backend.settings.STORAGES['staticfiles']['BACKEND'],
            'whitenoise.storage.CompressedStaticFilesStorage',
        )

    def test_uploaded_files_keep_the_default_storage(self):
        self.assertEqual(
            backend.settings.STORAGES['default']['BACKEND'],
            'django.core.files.storage.FileSystemStorage',
        )
