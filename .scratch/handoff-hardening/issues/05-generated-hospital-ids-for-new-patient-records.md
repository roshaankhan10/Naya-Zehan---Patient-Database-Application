# 05: Generated Hospital IDs for new Patient records

**Tracker:** GitHub issue #8 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/8

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#2 — Duplicate prevention: generated Hospital IDs and search-first registration

## What to build

Every new Patient record is issued a Hospital ID by the system, and the patient leaves with that number. A patient who returns with their number is found instantly and exactly — no matching, no guessing. This is the durable fix for duplication, and it is procedural rather than algorithmic.

Today the Hospital ID is typed in by hand, with no check that it is unique or even present.

The generated format must be visibly distinct from legacy numbering so it cannot collide with it, and so staff can tell at a glance which era a record comes from. Generation happens server-side, so two simultaneous registrations cannot produce the same number; the client no longer supplies a Hospital ID when creating a Patient record.

Uniqueness is enforced by a partial constraint covering only the new format. This is load-bearing: a constraint over the whole column would fail to apply against legacy data, which reuses numbers and omits them. Scoping it to the new format lets the guarantee hold going forward without touching a single historical row.

The field stays nullable. Records without a Hospital ID remain acceptable and are simply not findable by ID — no code may assume the field is present.

## Acceptance criteria

- [ ] Creating a Patient record without supplying a Hospital ID yields one in the new format
- [ ] The generated format cannot be confused with legacy Hospital IDs
- [ ] Two new Patient records can never share a generated Hospital ID, enforced at the database level
- [ ] The uniqueness constraint applies only to new-format IDs, and the migration succeeds against existing data
- [ ] Legacy records with duplicate or absent Hospital IDs remain readable and editable
- [ ] Looking up a Patient record by exact Hospital ID is a supported, first-class path
- [ ] The registration screen no longer asks for a Hospital ID and shows the issued number after registration
- [ ] The issued number is presented so it can be given to the patient

## Blocked by

- #4

