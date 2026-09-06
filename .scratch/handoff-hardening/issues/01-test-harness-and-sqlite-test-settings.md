# 01: Test harness and SQLite test settings

**Tracker:** GitHub issue #4 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/4

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

A test suite can be run safely against this project. Today `records/tests.py` is empty and every verification has been a manual curl against production; this ticket establishes the harness the rest of the work is built on.

Critically, tests must never touch the production database. `manage.py test` will try to create a test database on the Supabase pooler whenever `DATABASE_URL` is set, so tests run against a local SQLite database via a test-settings override.

The suite established here is the prior art for every ticket that follows, so its shape matters more than its coverage: accounts for an Admin, a superuser and a User, helpers to authenticate as each, and assertions written in the vocabulary of `CONTEXT.md`.

## Acceptance criteria

- [ ] Tests run against local SQLite regardless of whether `DATABASE_URL` is set
- [ ] Running the suite makes no connection to Supabase
- [ ] Reusable fixtures exist for an Admin, a superuser and a User
- [ ] A helper authenticates the test client as any of those roles
- [ ] At least one real test passes against an existing endpoint, asserting role behaviour through the HTTP API
- [ ] The command to run the suite is documented in `AGENTS.md`

## Blocked by

- None (can start immediately)

