# 14: Field-level history for Patient and Admission

**Tracker:** GitHub issue #17 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/17

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

An edit can be inspected to see what actually changed, not merely that a change happened.

Field-level history is kept for Patient records and Admissions. It writes rows only on change, which keeps it cheap, and it is what makes soft delete meaningful: a removed record whose history survives can actually be understood when restored.

An Admin can see the change history for a record.

## Acceptance criteria

- [ ] Editing a Patient record records which fields changed, from what to what
- [ ] The same applies to an Admission
- [ ] History rows are written only when something actually changes
- [ ] An Admin can view a record's change history in the app
- [ ] A User cannot view change history
- [ ] Soft delete and restore appear in the record's history
- [ ] Purging a record removes its history along with it

## Blocked by

- #13

