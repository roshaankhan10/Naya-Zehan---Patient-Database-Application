# Naya Zehan — Patient Records

The domain language of the Cowasjee Institute of Psychiatry record system: a mobile
application over ~223,000 patient records migrated from a legacy dBASE system.

This file is a glossary and nothing else. Decisions live in `docs/adr/`; the
non-ADR decision record lives in `docs/decisions-log.md`.

## People and records

**Patient**:
One *registration record* — a single row created when someone was registered at the
institute. It is deliberately **not** a person: the same human may hold several
Patient records from separate registrations over the years, and the system does not
claim to know which. See ADR-0002.
_Avoid_: person, individual (these imply an identity guarantee the data cannot make)

**Person**:
A human being. Intentionally **not** modelled in this system — there is no table, no
identifier, and no merge operation. Used only in prose, never as a code concept.

**Admission**:
One stay at the institute, belonging to exactly one Patient record. A Patient record
may have many Admissions; `is_current` marks an ongoing stay.

**Hospital ID**:
The institute's own patient number (`hospital_id`) — the reference a patient keeps
hold of, and the primary way staff find an existing record.

Legacy values are **not unique and may be absent**: the same number was historically
reused, and some records never had one. Those rows are left as they are, and are
simply not findable by ID.

New records are issued a **system-generated ID in a distinct format** that cannot
collide with legacy values, unique among new records. Nothing may assume a Patient
record has a Hospital ID.
_Avoid_: patient ID, record ID (both are ambiguous against the database primary key)

**NIC**:
The Pakistani national identity card number. Structurally the strongest identifier
available, but **present on well under 1% of records** — so it is a best-effort hint
when it happens to be there, never something the system depends on. No behaviour may
assume a Patient record has one.
_Avoid_: CNIC, identity number

## Access

**Admin**:
An account with `is_staff` or `is_superuser` set. Full create/edit/delete, manages
other accounts, and may purge. In the interface and all documentation this is the
only word used for the elevated role.
_Avoid_: staff, manager, management (**"staff" is actively misleading here** — Django's
`is_staff=True` marks an Admin, while the endpoint `/api/staff/create/` creates a User)

**User**:
An account with neither flag. May search and read every Patient record; may not
create, edit or delete anything.
_Avoid_: staff, viewer, read-only account

## Removal

**Soft delete**:
Marking a record as removed so it disappears from ordinary use while remaining in the
database and in its own history. This is what the delete action in the app performs.
_Avoid_: delete, remove (unqualified — they read as permanent)

**Purge**:
Permanently and irrecoverably destroying a soft-deleted record. A separate, deliberate
act, never the outcome of an ordinary delete.
_Avoid_: hard delete, clear, wipe
