# Local production rehearsal

A copy of production on a developer's laptop, rebuilt from the `.DBF` and CSV files in
the repo. Each release is tried against it before it reaches `main`, because
production holds real patient records, has no point-in-time restore, and has no staging
server. The reasoning is under "Branches and releases" in `docs/decisions-log.md`.

The rehearsal reproduces **production's current state**, not a blank database. It
imports at `main`'s schema using `main`'s own code, then migrates forward to the
staging branch's schema, in the order production will run those migrations.

**The patient data stays on this machine.** Do not copy the database, its dumps, or the
rehearsal folder to any cloud account, personal or otherwise.

## What you need

| Tool | Version used | Notes |
| --- | --- | --- |
| PostgreSQL server binaries | 18.2 | `pg_ctl`, `initdb`, `psql`, `pg_dump`, `pg_restore`. The MSYS2 `ucrt64` build works. |
| Anaconda (`conda`) | 25.7 | Used only to create the two Python interpreters. |
| Flutter | 3.47 | For the app. |

Everything the rehearsal creates lives **outside the repo**, in a sibling folder. These
steps call it `$REH`:

```powershell
$REH  = "C:\Ze_Works\Khidmat_Habib\nz-rehearsal"   # anywhere outside the repo
$REPO = "C:\Ze_Works\Khidmat_Habib\Naya-Zehan---Patient-Database-Application"
$PG   = "C:\msys64\ucrt64\bin"
```

Choose a local database password and a local Admin password when you get to those
steps. They protect nothing but this laptop's copy, so **don't reuse a real one, and
don't write them into this file.** The steps below call them `<db-password>` and
`<admin-password>`.

## 1. A local PostgreSQL cluster

The cluster runs on port **5433**, so it can't be mistaken for another PostgreSQL on the
default port.

```powershell
New-Item -ItemType Directory -Force "$REH\logs" | Out-Null
Set-Content -Encoding ascii "$REH\pw.txt" "<db-password>"
& "$PG\initdb.exe" -D "$REH\pgdata" -U nz --auth=scram-sha-256 --pwfile="$REH\pw.txt" -E UTF8
Remove-Item "$REH\pw.txt"

& "$PG\pg_ctl.exe" -D "$REH\pgdata" -l "$REH\logs\pg.log" -o "-p 5433" start
$env:PGPASSWORD = "<db-password>"
& "$PG\psql.exe" -h 127.0.0.1 -p 5433 -U nz -d postgres -c "CREATE DATABASE nz_rehearsal;"
```

To stop the cluster: `& "$PG\pg_ctl.exe" -D "$REH\pgdata" stop`.

## 2. Two Python interpreters

**3.13** is the target runtime (#21). **3.10** is what `render.yaml` asks Render for.
Render only honours `render.yaml` if the service was created as a Blueprint, so until
the owner confirms, assume 3.10 is what production actually runs.

```powershell
$conda = "$env:USERPROFILE\anaconda3\Scripts\conda.exe"
& $conda create -y -p "$REH\py313" python=3.13
& $conda create -y -p "$REH\py310" python=3.10

foreach ($v in "py313", "py310") {
    & "$REH\$v\python.exe" -m pip install -r "$REPO\requirements.txt" pandas dbfread
}
# Django 3.2 imports `cgi`, which Python 3.13 removed. Local-only, never in requirements.txt.
& "$REH\py313\python.exe" -m pip install legacy-cgi
```

`pandas` and `dbfread` are needed only by `import_all`, so they stay out of
`requirements.txt`.

Both interpreters must pass the suite:

```powershell
Set-Location $REPO
& "$REH\py313\python.exe" manage.py test --settings=backend.settings_test
& "$REH\py310\python.exe" manage.py test --settings=backend.settings_test
```

## 3. Import at `main`'s schema, from `main`'s code

`main`'s code is checked out into a **detached** worktree, so that nothing can be
committed to `main` from it:

```powershell
git -C $REPO worktree add --detach "$REH\main-checkout" main
```

Every Django command against the rehearsal database needs these variables. Set them in
each new shell. **Check that `DATABASE_URL` says `127.0.0.1:5433` before running
anything**, because production's URL is the only other one that could be there.

```powershell
$env:DATABASE_URL = "postgres://nz:<db-password>@127.0.0.1:5433/nz_rehearsal"
$env:SECRET_KEY   = "local-rehearsal-only"
$env:DEBUG        = "True"
$env:PYTHONIOENCODING = "utf-8"   # import_all prints ✓ and ══
```

Migrate and import with Python 3.10, which is what production may have run:

```powershell
Set-Location "$REH\main-checkout"
& "$REH\py310\python.exe" manage.py migrate
& "$REH\py310\python.exe" manage.py import_all > "$REH\logs\import.log" 2>&1
```

`import_all` reads patients from `PATREC2.csv`, not from `PATREC.DBF`, and admissions
from `INDOOR1.DBF`. That is `main`'s code, so it is what production was loaded with.
The CSV is a partial export: it has 76 fewer rows than the DBF (see the results below).
The import takes a few minutes.

Record the counts:

```powershell
& "$PG\psql.exe" -h 127.0.0.1 -p 5433 -U nz -d nz_rehearsal -c "
  select (select count(*) from records_patient)   as patients,
         (select count(*) from records_admission) as admissions,
         (select count(*) from records_admission where patient_id is not null) as linked_admissions;"
```

Then snapshot the database, so the rehearsal can be reset to production's state in
seconds instead of re-importing:

```powershell
& "$PG\pg_dump.exe" -h 127.0.0.1 -p 5433 -U nz -Fc -f "$REH\main-schema.dump" nz_rehearsal
```

To reset later, drop and recreate `nz_rehearsal`, then run
`& "$PG\pg_restore.exe" -h 127.0.0.1 -p 5433 -U nz -d nz_rehearsal "$REH\main-schema.dump"`.

## 4. Migrate forward to the staging branch's schema

This is the rehearsal of **Release A**: the same migrations, on the same data, in the
same order as production. Run it from the `release-a` tag, not from the staging branch's
tip, because staging keeps moving after the release is cut. For Release B, do the same
with its tag.

```powershell
git -C $REPO worktree add --detach "$REH\release-a" release-a
Set-Location "$REH\release-a"
$env:DATABASE_URL   # must say 127.0.0.1:5433 — stop here if it doesn't
& "$REH\py310\python.exe" manage.py migrate --plan   # read it before applying
& "$REH\py310\python.exe" manage.py migrate
```

Re-run the count query from step 3. Each number must be unchanged.

## 5. Serve the backend and log in as an Admin

```powershell
$env:DJANGO_SUPERUSER_PASSWORD = "<admin-password>"
& "$REH\py313\python.exe" manage.py createsuperuser --noinput --username rehearsal_admin --email rehearsal@example.invalid
Remove-Item Env:DJANGO_SUPERUSER_PASSWORD

# The Flutter web app (step 6) is served from localhost:5000.
$env:CORS_ALLOWED_ORIGINS = "http://localhost:5000,http://127.0.0.1:5000"
& "$REH\py313\python.exe" manage.py runserver 127.0.0.1:8000
```

Check the API directly. The token endpoint is rate limited to 5 requests a minute.

```bash
B=http://127.0.0.1:8000/api
TOK=$(curl -s -X POST $B/token/ -H 'Content-Type: application/json' \
  -d '{"username":"rehearsal_admin","password":"<admin-password>"}' \
  | python -c "import sys,json; print(json.load(sys.stdin)['access'])")
curl -s -H "Authorization: Bearer $TOK" $B/me/
curl -s -H "Authorization: Bearer $TOK" $B/patients/   | python -c "import sys,json; print(json.load(sys.stdin)['count'])"
curl -s -H "Authorization: Bearer $TOK" $B/admissions/ | python -c "import sys,json; print(json.load(sys.stdin)['count'])"
```

The two counts must match the database. Then the two calls the app makes when you
search and when you open a patient:

```bash
curl -s -H "Authorization: Bearer $TOK" "$B/patients/?search=<a name or Hospital ID>" \
  | python -c "import sys,json; print(json.load(sys.stdin)['count'])"
curl -s -H "Authorization: Bearer $TOK" "$B/admissions/?patient=<a patient id>" \
  | python -c "import sys,json; print(json.load(sys.stdin)['count'])"
```

## 6. Run the Flutter app against the local backend

```powershell
Set-Location "$REPO\khidmat_mobile"
flutter run -d chrome --web-port 5000 --web-hostname localhost --dart-define=BASE_URL=http://127.0.0.1:8000/api
```

Then, in the app:

1. Log in as `rehearsal_admin`.
2. Search for a patient by name and by Hospital ID.
3. Open a patient who has admissions, and check the admissions list loads.

The Windows desktop target (`-d windows`) works too, but it needs Windows **Developer
Mode** switched on because plugins require symlinks. An Android emulator reaches the
laptop at `http://10.0.2.2:8000/api`.

## Results of the first rehearsal (2026-10-03)

| | Patients | Admissions | Linked admissions |
| --- | --- | --- | --- |
| Imported at `main`'s schema | 123,181 | 13,338 | 11,344 |
| After migrating to staging (`0002`) | 123,181 | 13,338 | 11,344 |

Where the numbers come from:

- `PATREC.DBF` holds 123,470 Patient records, none marked deleted. `PATREC2.csv` has
  123,394 rows, so 76 records never reached the CSV. `import_all` then skipped 213 CSV
  rows that were empty or had no name.
- `INDOOR1.DBF`'s header claims 13,342 records, but only 13,338 can be read, and all of
  them were imported.

Step 4 was run from `ff76406`, the commit the `release-a` tag points to.

- **Tests:** the full suite passed on Python 3.13.16 and on 3.10.22.
- **API, checked with curl:** as an Admin, all of these answered correctly, including the
  CORS preflight from the app's origin: login, `/me/`, the Patient and Admission lists,
  search, and `/admissions/?patient=<id>`.
- **App:** the Flutter web build was served against the local backend, and the
  developer clicked through step 6: login, search, and opening a patient's admissions all
  worked. The backend log confirms each request.
- **Bug found in the app, already present on `main`:** an admission with no linked
  patient still shows "View Full Patient Details". Tapping it requests
  `/admissions/?patient=null`, the backend returns a 500 (`int('null')` in
  `AdmissionViewSet.get_queryset`), and the app swallows the error and shows an empty
  list. 1,994 admissions are unlinked.

**The ticket's "all ~223,000 Patient records" could not be met**: the repo only holds
the 123,181 imported here. That finding and one about migration `0002` are under "Open
items" in `docs/decisions-log.md`.
