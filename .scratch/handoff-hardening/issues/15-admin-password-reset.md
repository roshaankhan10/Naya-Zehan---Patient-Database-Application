# 15: Admin password reset

**Tracker:** GitHub issue #18 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/18

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#3 — Account management: create, reset, deactivate

## What to build

An Admin can reset a member of staff's password, so a forgotten password is resolved on site in minutes instead of requiring a developer with database access.

The new password takes effect immediately and the old one stops working. The project's existing password rules apply, so a reset cannot quietly weaken security relative to what account creation enforces.

## Acceptance criteria

- [ ] An Admin can set a new password for an existing account
- [ ] The account can sign in with the new password immediately
- [ ] The old password no longer works
- [ ] Password rules are enforced and a weak password is rejected with a readable error
- [ ] A User cannot reset anyone's password, including their own, and is refused by the server directly
- [ ] The reset is written to the access log, naming the acting Admin and the affected account

## Blocked by

- #14

