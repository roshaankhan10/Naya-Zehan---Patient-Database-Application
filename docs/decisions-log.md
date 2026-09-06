# Decision log

Decisions that shape the system but don't warrant an ADR — conventional enough that
nobody will be surprised, but with reasoning that would otherwise be lost. The two
genuinely surprising decisions live in `docs/adr/`. Vocabulary lives in `CONTEXT.md`.

Settled in a design session on 2026-09-06. Nothing here is implemented yet unless the
item says so.

---

## Goal of the remaining work

**Hand the system off.** The institute runs it without the current developer, staffed
by people with minimal technical expertise. Not a demo, and not a product under
continuing development. Every decision below is weighted toward *survivability after
handoff* rather than toward features.

This is a higher bar than the roadmap's remaining phases imply: a signed APK that
works is not the same as a system that is still running in a year.

## Roles and access

**Admin / User**, mapped to Django's flags in exactly one place:
`Admin = is_staff or is_superuser`, `User = everyone else`.

The rename is a fix to *language*, not to code: `is_staff=True` marks an Admin while
`/api/staff/create/` creates a User, so the word "staff" means opposite things in
adjacent lines. The endpoint URL stays as it is — renaming a live route risks the
Flutter client for no benefit. Rejected `Manager/Staff` (re-uses the poisoned word)
and `Administrator/Clinician` (breaks when a records clerk gets a read-only account).

**Search stays broad** (`religion`, `sex`, `occupation`, `address` and the rest).
Raised as a profiling risk — a User can query for cohorts, not just look up a known
patient — and deliberately accepted, because the audience is clinicians. Noted so the
next reader knows it was a choice. The *performance* cost is separate and real: 13
unindexed `ILIKE` scans over 223K rows on free-tier hardware.

## Deletion

**Soft delete by default.** The delete action marks a record removed and filters it
from ordinary queries; nothing leaves the database. This is the single most dangerous
operation in the app — a trash icon on a phone, pressed by a non-technical user, on
infrastructure with no point-in-time restore — and soft delete converts it into a
recoverable one. It also makes `Admission.patient`'s `on_delete=CASCADE` survivable:
today, deleting a patient silently destroys their entire admission history.

**Purge** is separate and deliberate:

- An **Admin** may purge a single record.
- Only a **superuser** may bulk-purge the deleted bin.
- **There is no clear-everything capability**, and none should be added. A wipe
  button reachable from a phone is one tap from destroying an irreplaceable
  223,000-record migration.
- Confirmation is **typed** (the patient's name, or the record count), not tapped. A
  dialog that can be dismissed reflexively is not a safeguard.

Purge exists for *"this record was created in error and must genuinely cease to
exist"*, **not** to save space. Soft-deleted patients are a rounding error against a
500MB budget; the access log below is what actually grows.

## Duplicate prevention

The design is in ADR-0002; the implementation consequences are here.

- **Search-first on registration.** Before creating a Patient record, show likely
  existing matches on name + father_name. Advisory only — no blocking anywhere.
- **System-generated Hospital ID for new records**, in a format that cannot collide
  with legacy values, with uniqueness enforced by a **partial unique index covering
  only the new format**. This is deliberate: a constraint over the whole column would
  fail against legacy data, which reuses numbers. Removing the manual entry step also
  suits an audience with minimal technical expertise.
- **`hospital_id` stays nullable.** Legacy gaps remain, records without an ID are
  acceptable, and they are simply excluded from ID-based lookup rather than treated as
  errors. No code may assume the field is present.
- **NIC captured, never required** — see ADR-0002 for why a mandatory NIC would be
  actively harmful here.
- **NIC-based routing was proposed and reversed on measurement.** It was recommended
  on the reasoning that NIC is the only true person-identifier in the schema; the data
  showed coverage of well under 1% (likely 0.1–0.2% after stripping malformed values).
  Recorded so it is not re-proposed: the mechanism would have almost never fired while
  creating the impression duplicates were being caught.

## Audit trail

Nothing currently records who read which patient, and this cannot be fixed
retrospectively — history not captured is gone. For psychiatric records, unauthorised
*reading* is the realistic incident, not unauthorised editing.

- **Access log**: writes, logins, and record views. Searches are logged as counts,
  **not search terms** — storing every name a clinician typed creates a new sensitive
  dataset that would itself need protecting.
- **`django-simple-history`** on `Patient` and `Admission` for field-level history.
  It only writes rows on change, and it is what makes soft delete meaningful.
- **Retention**: a rolling window of a couple of months, pruned on a schedule.
  Recorded honestly: 12–24 months was recommended and costs almost nothing
  (~0.3MB/month at ~200 record views per day, so ~7MB for two years). A short window
  was chosen anyway for this niche audience; the trade-off is that incidents surfacing
  late — a complaint in March about something in November — become unanswerable.

Related, and still open: **Django `/admin/` is a second full-CRUD door** into all
223K records, reachable on the public internet, bypassing `IsAdminOrReadOnly` and any
audit logging. It should be locked down or removed before handoff.

## Infrastructure

**Stay on the free tier**, and engineer around it rather than pretending it is safe.
Free-tier Supabase projects pause after roughly a week of inactivity and have no
point-in-time restore; free Render services spin down and cold-start slowly enough
that users will report the app as broken. After handoff there is nobody on site who
can un-pause a project or restore a database.

- **Scheduled `pg_dump` via GitHub Actions** to storage the **institute owns**. A
  backup living in a departed developer's personal account is not a backup.
- **Keep-alive pings via GitHub Actions** to stop the project pausing and the service
  spinning down. Chosen over a cron on someone's machine, which dies with that machine.
- **A restore must be tested once** into a scratch database before handoff. An
  untested dump is a hope, not a backup.
- **Institute accounts are added as owners** of GitHub, Supabase, Render and the
  backup destination after setup.

Upgrading (~$30/month total) was recommended and declined; the above is the agreed
mitigation. The non-negotiable piece in any version is the off-Supabase backup: the
source data is legacy dBASE dumps, and losing the database means redoing the entire
migration.

## Account management

A small **in-app admin screen**, because after handoff the only way to create an
account is a curl call nobody there can make, and the other door (Django `/admin/`)
is being locked down. It covers: list users, create user, **reset password**,
**deactivate user**.

Password resets and departing employees are certainties, not edge cases — today there
is no way to revoke a departed nurse's access, and her refresh token stays valid for a
day regardless. Deactivation should **blacklist the user's refresh tokens**;
`token_blacklist` is already installed and currently doing nothing.

Admin promotion/demotion is deliberately **excluded** — rare, high-consequence, fine
to handle out of band.

**Real staff accounts should be created before handoff**, so the first thing the
institute needs is not the thing that is hardest.

## Testing

There are currently **zero** automated tests; every verification to date was a manual
curl against production. That is why the same class of silent bug has recurred four
times (`id` vs `hospital_id` twice, paginated-response casting twice).

A thin API suite covering auth, role enforcement, patient CRUD, admission filtering,
and soft-delete/purge behaviour. The point is not a future maintainer — it is making
the changes listed on this page safely against a live database holding 223,000
irreplaceable records with no restore path.

---

## Open items

- **Escalation contact.** Ownership is settled (institute accounts added after setup),
  but not *"the database needs restoring and nobody here can run psql"*. The handoff
  document needs either a **named contact with a bounded scope** ("best effort,
  emergencies only") or an explicit statement that there is none and the institute
  accepts the risk. Currently unfilled.
- ~~**Duplicate-NIC check — blocks work.**~~ **No longer blocking, and no longer
  relevant.** Measurement showed NIC is populated on well under 1% of patients (likely
  0.1–0.2% once malformed values are stripped), so NIC-based routing was dropped
  entirely — see ADR-0002. It remains an optional best-effort match when present;
  nothing depends on it. A partial unique index on NIC is still worth adding as a
  data-integrity guard, but it is no longer on the critical path for anything.

- **Duplicate-scale figures** (not blocking, but the institute should know what it is
  inheriting): count of duplicate `(name, father_name, age)` groups, count of
  `hospital_id` values used by more than one row, and current table sizes.
- **Admin password rotation** — flagged as exposed in shell history during testing,
  never confirmed done.
- **Silently dropped admissions.** `import_admissions.py` skips any admission whose
  `hospital_id` matches no patient, without counting them, and resolves matches with
  `.filter(...).first()` — so with duplicate hospital IDs an admission attaches to an
  arbitrary row. Nobody knows how many admissions were lost on import.

## Housekeeping found while reading the repo

- `khidmat_mobile/lib/api_config.dart` — dead code, still present despite being
  flagged for deletion repeatedly.
- `records/urls.py` — a stale duplicate of `backend/urls.py` (missing `MeView`) that
  nothing imports. Two files that look authoritative; one is a decoy.
- `src/index.tsx`, `src/patients.tsx` — an abandoned React prototype defining a third,
  contradictory `Patient` shape (`bloodType`, `phone`, `condition`, `status`).
- `Admission.hospital_id_ref` — a fossil of the abandoned linking strategy; populated
  by no importer, exposed by no serializer.
- `AdmissionSerializer` — `patient_name` and `patient_hospital_id` are each declared
  twice.
- `TIME_ZONE = 'UTC'` while the institute is UTC+5.
