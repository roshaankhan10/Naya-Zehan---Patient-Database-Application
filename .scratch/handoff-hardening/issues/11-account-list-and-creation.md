# 11: Account list and creation

**Tracker:** GitHub issue #14 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/14

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#3 — Account management: create, reset, deactivate

## What to build

An Admin can see and create accounts from inside the app.

Today the only way to create an account is an API call made by hand with an Admin token, and the other door — the framework admin site — is being closed. After handover the institute will be staffed by people with minimal technical expertise, so in practice nobody there can currently add a new member of staff.

The screen lists every account with its role, whether it is active, and when it last signed in — so an Admin can see who has access to patient records. Creating an account produces a User: elevated access must always be a deliberate act, never a default.

Everything is expressed as Admin and User, never in the framework's own flags. Note the trap in `CONTEXT.md`: the staff flag marks an Admin, and the endpoint whose URL contains "staff" creates a User. That endpoint keeps its URL — renaming a live route risks the working client for no functional gain — but nothing in the interface repeats the confusion.

Promotion and demotion between Admin and User are deliberately out of scope.

## Acceptance criteria

- [ ] An Admin can see a list of all accounts
- [ ] The list shows each account's role, active state, and last sign-in
- [ ] An Admin can create an account from the app
- [ ] A newly created account is a User and can sign in
- [ ] A duplicate username is rejected with a clear, readable error
- [ ] Password rules are enforced on creation
- [ ] A User cannot see the screen and is refused by the server if they call the endpoints directly
- [ ] Account creation is written to the access log with the acting Admin
- [ ] The interface says Admin and User, never the framework's flags
- [ ] The screen is reachable from an obvious place in the app

## Blocked by

- #4
- #7

