# 02: Remove decoys and dead code

**Tracker:** GitHub issue #5 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/5

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

Nothing changes for users. This is prefactoring: remove the files and fields that mislead anyone reading this repo, so later tickets are edits to an unambiguous codebase.

Four decoys exist today. There is a stale duplicate URL configuration in the records app that no longer matches the real one and that nothing imports — two files that both look authoritative. The Flutter app carries an unused config class alongside the real one. An abandoned React prototype in the repo root defines a third, contradictory shape for a Patient record. And the Admission model carries a raw hospital-id reference field, a fossil of the abandoned linking strategy, populated by no importer and exposed by no serializer.

The Admission serializer also declares two of its read-only patient fields twice.

## Acceptance criteria

- [ ] The stale duplicate URL configuration in the records app is deleted
- [ ] The unused Flutter config class is deleted and nothing references it
- [ ] The abandoned React prototype is removed from the repo root
- [ ] The unused raw hospital-id reference field is removed from the Admission model, with a migration
- [ ] Duplicate field declarations in the Admission serializer are removed
- [ ] The API responses for patients and admissions are unchanged
- [ ] The test suite passes

## Blocked by

- None (can start immediately)

