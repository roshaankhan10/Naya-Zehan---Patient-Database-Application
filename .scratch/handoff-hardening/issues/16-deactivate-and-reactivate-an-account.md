# 16: Deactivate and reactivate an account

**Tracker:** GitHub issue #19 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/19

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#3 — Account management: create, reset, deactivate

## What to build

When an employee leaves, their access ends — immediately.

Today there is no way to end access at all: the account stays valid indefinitely, and a developer with database access is the only remedy. A departed employee keeping a working login to ~223,000 psychiatric records is not an edge case; staff turnover is routine.

Marking the account inactive is not enough on its own. An already-issued refresh token stays valid for a further day, so deactivation must also blacklist the account's outstanding refresh tokens. The blacklist machinery is already installed in this project and currently does nothing; this is what it is for. A short residual window on an already-issued access token is accepted; the day-long refresh window is not.

Sign-in refuses inactive accounts and says so distinctly, rather than reporting invalid credentials — a deactivated employee retrying their correct password should learn to contact an Admin.

Reactivation exists for someone deactivated in error or returning to work, and requires signing in again rather than resurrecting the old session.

Two interlocks, enforced server-side: an account cannot deactivate itself, and the last remaining active Admin cannot be deactivated. Both failure modes end with the institute locked out of its own system and nobody on site able to recover it.

## Acceptance criteria

- [ ] An Admin can deactivate an account
- [ ] A deactivated account cannot sign in
- [ ] Sign-in tells a deactivated account that it is inactive, distinctly from wrong credentials
- [ ] A refresh token issued before deactivation no longer produces a usable session
- [ ] An Admin can reactivate an account, and it can sign in again afterwards
- [ ] An account cannot deactivate itself, enforced by the server
- [ ] The last remaining active Admin cannot be deactivated, enforced by the server
- [ ] A User cannot deactivate or reactivate anyone
- [ ] Deactivation and reactivation are written to the access log

## Blocked by

- #14

