# 13: Purge a single Patient record

**Tracker:** GitHub issue #16 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/16

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#1 — Soft delete, purge, and the access log

## What to build

An Admin can permanently destroy a single removed record that was created in error, so genuine junk does not linger forever.

Purge is a separate, deliberate act — not the same operation as delete, and not reachable by the same call. It requires typing the patient's name rather than tapping a button: a dialog that can be dismissed reflexively is not a safeguard. The confirmation states plainly that the data cannot be recovered, so nobody is relying on assumptions about backups.

Purging destroys the Patient record, its Admissions, and its field-level history. Its access-log entry survives — a log that disappears along with the thing it describes is not a log.

Purge exists for correctness, not for saving space: removed records are a rounding error against the storage budget.

## Acceptance criteria

- [ ] An Admin can permanently destroy a single removed Patient record
- [ ] The action requires typing the patient's name, matched before it proceeds
- [ ] The confirmation states that the data cannot be recovered
- [ ] The record, its Admissions and its history are genuinely gone afterwards
- [ ] The access-log entries about that record survive the purge
- [ ] The purge itself is written to the access log
- [ ] A User is refused by the server
- [ ] Purge is a distinct operation and cannot be triggered by the ordinary delete call

## Blocked by

- #13

