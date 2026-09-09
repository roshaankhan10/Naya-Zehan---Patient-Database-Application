"""The harness proves itself: the suite cannot reach the production database."""
import importlib
import os
from unittest import mock

from django.db import connection
from django.test import SimpleTestCase

import backend.settings
import backend.settings_test


class DatabaseIsolationTest(SimpleTestCase):
    SUPABASE_URL = (
        'postgres://user:pw@aws-1-ap-northeast-2.pooler.supabase.com:5432/postgres'
    )

    def test_the_live_connection_is_local_sqlite(self):
        self.assertEqual(connection.vendor, 'sqlite')
        self.assertFalse(connection.settings_dict.get('HOST'))

    def test_a_supabase_database_url_does_not_reach_the_settings(self):
        """The override holds even when the environment points at production.

        Both modules are re-evaluated under a hostile `DATABASE_URL`, so this
        exercises the real precedence rather than the values already imported.
        Reloading is safe: `django.conf.settings` copied its values at startup
        and does not read these modules again.
        """
        with mock.patch.dict(os.environ, {'DATABASE_URL': self.SUPABASE_URL}):
            try:
                importlib.reload(backend.settings)
                self.assertIn(
                    'supabase', str(backend.settings.DATABASES['default']).lower(),
                    'the hostile DATABASE_URL never reached backend.settings, so '
                    'this test would pass no matter what settings_test did',
                )
                reloaded = importlib.reload(backend.settings_test)
            finally:
                importlib.reload(backend.settings)

        self.assertEqual(
            reloaded.DATABASES['default']['ENGINE'], 'django.db.backends.sqlite3',
        )
        self.assertNotIn('supabase', str(reloaded.DATABASES['default']).lower())
