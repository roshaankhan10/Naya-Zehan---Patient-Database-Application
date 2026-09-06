# Naya Zehan — Patient Database Application

A mobile application over ~223,000 psychiatric patient records migrated from a legacy
dBASE system at the Cowasjee Institute of Psychiatry, Hyderabad.

Flutter (`khidmat_mobile/`) → Django REST API (`backend/`, `records/`) → Supabase (PostgreSQL).
The Flutter app never talks to the database directly.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `roshaankhan10/Naya-Zehan---Patient-Database-Application`,
via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical labels, unchanged: `needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Read before changing anything

- **`CONTEXT.md`** — the glossary. Note especially that a `Patient` row is a
  *registration record, not a person*, and that "staff" is a poisoned word here
  (`is_staff=True` marks an **Admin**, while `/api/staff/create/` creates a **User**).
- **`docs/adr/0002-registration-record-not-person.md`** — why 223,000 rows were never
  deduplicated, and why NIC-based matching was proposed and reversed. Both are things a
  reader will otherwise be tempted to "fix".
- **`docs/decisions-log.md`** — the decisions that didn't warrant an ADR, with their
  reasoning, plus open items and known dead code.

## Operating constraints

- The database holds **real patient records** and runs on a free tier with **no
  point-in-time restore**. Treat destructive operations accordingly.
- Tests must never run against the production database. `manage.py test` will try to
  create a test database on the Supabase pooler if `DATABASE_URL` is set — run tests
  against local SQLite via a test-settings override.
