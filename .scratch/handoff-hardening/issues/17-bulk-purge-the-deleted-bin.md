# 17: Bulk purge the deleted bin

**Tracker:** GitHub issue #20 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/20

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

A superuser can empty the deleted bin in one action, so records accumulated over a long period can be cleared deliberately.

This is the most dangerous operation in the system, so it is limited to the fewest people: an Admin who is not a superuser cannot perform it. It requires typing the number of records affected, so a bulk destruction cannot happen by reflex.

The deleted bin is the only bulk target. There is no capability anywhere that destroys all records at once, and none is to be added — a wipe button reachable from a phone is one tap away from destroying an irreplaceable migration of ~223,000 records.

## Acceptance criteria

- [ ] A superuser can permanently destroy every record in the deleted bin in one action
- [ ] The action requires typing the number of affected records, matched before it proceeds
- [ ] An Admin who is not a superuser is refused by the server
- [ ] A User is refused by the server
- [ ] Only removed records are destroyed; records in ordinary use are untouched
- [ ] The action is written to the access log with the count destroyed
- [ ] No endpoint or screen exists that destroys all records regardless of removal state

## Blocked by

- #15
- #16

