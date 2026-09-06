# 10: Soft delete and restore

**Tracker:** GitHub issue #13 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/13

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

Deleting stops being permanent.

Today an Admin taps a trash icon and the Patient record is destroyed, taking every Admission with it, on a database with no point-in-time restore and no undo. After this ticket, deleting marks the record removed instead: it disappears from search, lists and detail views for everyone, ordinary use is unchanged, and the data is still there. Restoring brings the record and its Admissions back whole.

Removed records are excluded by default at the model manager level, so every list, search, detail fetch and relation is covered without each one remembering. Seeing removed records is an explicit opt-in used only by the deleted bin and restore. This is deliberate: the failure mode to design against is a future endpoint leaking removed records because nobody thought to filter.

The delete operation keeps its existing API verb and its Admin-only requirement; only its behaviour changes. An Admission can also be removed on its own without touching its Patient record.

The database-level cascade stays as it is — it now only fires on Purge.

App copy tells the Admin the deletion is recoverable.

## Acceptance criteria

- [ ] Deleting a Patient record marks it removed rather than destroying it
- [ ] A removed Patient record is absent from list, search and detail for both Admin and User
- [ ] Its Admissions are removed from view too
- [ ] Restoring brings back both the Patient record and its Admissions
- [ ] An Admission can be removed on its own, leaving its Patient record intact
- [ ] Exclusion is the default at the manager level; showing removed records requires an explicit opt-in
- [ ] A User cannot delete or restore anything
- [ ] Delete, restore, and who performed them are written to the access log
- [ ] The app tells the Admin that deletion is recoverable

## Blocked by

- #4
- #7

