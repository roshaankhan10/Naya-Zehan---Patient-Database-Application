"""Settings for the test suite.

Tests must never touch the production database. `manage.py test` would otherwise
create and drop a test database on the Supabase pooler whenever `DATABASE_URL` is
set, so this module overrides `DATABASES` outright after importing the real
settings.

Run the suite with:

    python manage.py test --settings=backend.settings_test
"""
import os

# Pinned before the import below so that anything reading the environment during
# settings import — django-environ's read_env(), which uses os.environ.setdefault()
# and so cannot overwrite this — sees SQLite rather than the pooler. The DATABASES
# override further down is what actually decides the connection.
os.environ['DATABASE_URL'] = 'sqlite://:memory:'
os.environ.setdefault('SECRET_KEY', 'test-only-secret-key-never-used-in-production')

from .settings import *  # noqa: F401,F403,E402

# Whatever the environment or a local .env said, the suite runs in memory.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

# settings.py switches these on whenever DEBUG is false. SECURE_SSL_REDIRECT in
# particular turns every test request into a 301 to https://.
SECURE_SSL_REDIRECT = False
SECURE_HSTS_SECONDS = 0
SESSION_COOKIE_SECURE = False
CSRF_COOKIE_SECURE = False

# backend/urls.py rate limits the token endpoint to 5 requests a minute per IP.
# Tests authenticate far more often than that, and all from the same address.
RATELIMIT_ENABLE = False

PASSWORD_HASHERS = ['django.contrib.auth.hashers.MD5PasswordHasher']
