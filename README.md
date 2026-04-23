# Naya Zehan — Patient Database Application

A cross-platform mobile application for **Sir Cowasjee Jehangir Institute of Psychiatry, Hyderabad** to search, view, and manage patient records migrated from legacy dBASE (`.dbf`) files.

## Architecture

```
┌──────────────────┐       REST API        ┌───────────────────┐
│   Flutter App    │ ◄──── (JSON/JWT) ────► │  Django Backend   │
│  (Android/iOS)   │                        │  (DRF + Postgres) │
└──────────────────┘                        └───────────────────┘
```

- **Backend:** Django 3.2 + Django REST Framework + PostgreSQL
- **Frontend:** Flutter (cross-platform — Android, iOS, Web, Desktop)
- **Auth:** JWT (SimpleJWT) — access + refresh tokens
- **Data Source:** Legacy dBASE `.dbf` files → CSV → PostgreSQL

---

## Prerequisites

- Python 3.8+
- PostgreSQL 13+
- Flutter SDK 3.8+
- Android Studio / Xcode (for mobile builds)

---

## Backend Setup

### 1. Create PostgreSQL database

```sql
CREATE DATABASE khidmat_db;
CREATE USER your_db_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE khidmat_db TO your_db_user;
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your database credentials and secret key
```

### 3. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 4. Run migrations

```bash
python manage.py migrate
```

### 5. Create superuser

```bash
python manage.py createsuperuser
```

### 6. Import legacy data

```bash
# Import patients first (from converted CSV)
python manage.py import_patients --file PATREC2.csv

# Then import admissions (requires patients to exist)
python manage.py import_admissions --file INDOOR1.csv

# Use --dry-run to validate without saving
python manage.py import_patients --file PATREC2.csv --dry-run
```

### 7. Start the server

```bash
# Development
python manage.py runserver 0.0.0.0:8000

# This binds to all interfaces so mobile devices on the same LAN can connect
```

---

## Flutter App Setup

### 1. Configure server URL

Edit `khidmat_mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // For Android emulator → host machine:
  static const String baseUrl = 'http://10.0.2.2:8000';

  // For physical device on same LAN:
  // static const String baseUrl = 'http://192.168.x.x:8000';
}
```

### 2. Install dependencies

```bash
cd khidmat_mobile
flutter pub get
```

### 3. Run the app

```bash
# Android
flutter run

# Build APK for distribution
flutter build apk --release
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/token/` | Login (get JWT tokens) |
| `POST` | `/api/token/refresh/` | Refresh access token |
| `GET` | `/api/patients/` | List patients (paginated) |
| `GET` | `/api/patients/{id}/` | Patient detail + admissions |
| `GET` | `/api/patients/search/?name=&hospital_id=&father_name=&surname=` | Multi-param search |
| `POST` | `/api/patients/` | Create patient |
| `PUT` | `/api/patients/{id}/` | Update patient |
| `DELETE` | `/api/patients/{id}/` | Delete patient |
| `GET` | `/api/admissions/` | List admissions |
| `POST` | `/api/admissions/` | Create admission |
| `DELETE` | `/api/admissions/{id}/` | Delete admission |

All endpoints (except token) require `Authorization: Bearer <access_token>` header.

---

## Data Models

### Patient
| Field | Type | Description |
|-------|------|-------------|
| `hospital_id` | CharField (PK) | Unique hospital registration number |
| `name` | CharField | Patient full name |
| `father_name` | CharField | Father's or husband's name |
| `surname` | CharField | Family/clan name |
| `nic` | CharField | National Identity Card number |
| `dob` | DateField | Date of birth |
| `age` | IntegerField | Age in years |
| `sex` | CharField | M/F |
| `marital_status` | CharField | S/M/W/D |
| `religion` | CharField | Religion |
| `education` | CharField | Education level |
| `occupation` | CharField | Occupation |
| `address` | TextField | Full address |

### Admission
| Field | Type | Description |
|-------|------|-------------|
| `patient` | ForeignKey → Patient | Link to patient |
| `date_of_admission` | DateField | Admission date |
| `ward_no` | CharField | Ward number |
| `ref_source` | CharField | Referral source |
| `is_current` | BooleanField | Currently admitted flag |

---

## Project Structure

```
Naya-Zehan---Patient-Database-Application/
├── backend/                    # Django project settings
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── records/                    # Django app — models, views, serializers
│   ├── models.py
│   ├── views.py
│   ├── serializers.py
│   ├── admin.py
│   └── management/commands/    # Data import scripts
├── khidmat_mobile/             # Flutter mobile app
│   └── lib/
│       ├── main.dart
│       ├── config/             # API config, theme
│       ├── models/             # Typed Dart models
│       ├── services/           # API & Auth services
│       ├── providers/          # State management
│       ├── screens/            # All app screens
│       └── widgets/            # Reusable UI components
├── *.DBF / *.csv               # Legacy data files
├── requirements.txt            # Python dependencies
└── .env.example                # Environment variable template
```

---

## Deployment Checklist

- [ ] Set `DEBUG = False` in production
- [ ] Set a strong `DJANGO_SECRET_KEY`
- [ ] Configure `ALLOWED_HOSTS` with server IP/domain
- [ ] Set `CORS_ALLOWED_ORIGINS` instead of allowing all
- [ ] Use a production WSGI server (Gunicorn / uWSGI)
- [ ] Set up PostgreSQL backups
- [ ] Update Flutter `ApiConfig.baseUrl` to production server
- [ ] Build release APK: `flutter build apk --release`
- [ ] Test JWT token refresh flow