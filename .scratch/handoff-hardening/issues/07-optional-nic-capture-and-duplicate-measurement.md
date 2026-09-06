# 07: Optional NIC capture and duplicate measurement

**Tracker:** GitHub issue #10 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/10

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#2 — Duplicate prevention: generated Hospital IDs and search-first registration

## What to build

Two parts: a measurement, then a small feature that depends on its result.

**Measure first.** Count the duplicate non-empty NIC values in the existing data. This decides whether a partial unique constraint on NIC can be applied at all — if the legacy import already contains collisions, the migration fails. While in the database, also capture the figures the institute should have at handover: how many duplicate name / father-name / age groups exist, how many Hospital IDs are used by more than one record, and the current table sizes. Record all of these in `docs/decisions-log.md`.

**Then the feature.** NIC is captured at registration when the patient has one, and is never required. Requiring it would be wrong for this population specifically: admissions include minors, people brought in by others, and patients arriving in crisis with no documents — and a mandatory field of that kind gets filled with placeholder digits to get past it.

Where present, NIC may contribute to candidate matching. Nothing depends on it being there. NIC is populated on well under 1% of records, so no behaviour may treat it as reliable — see ADR-0002, which records an earlier design that routed on NIC and was reversed on measurement.

## Acceptance criteria

- [ ] The duplicate-NIC count is measured and recorded in `docs/decisions-log.md`
- [ ] Duplicate-scale figures and table sizes are recorded for the handoff document
- [ ] NIC can be entered at registration and is saved
- [ ] A Patient record can be created with no NIC, and behaves identically to one with a NIC
- [ ] NIC is never required by any form or endpoint
- [ ] A partial unique constraint on non-empty NIC values is added if the measurement shows it can be, and the decision either way is recorded
- [ ] Where present, NIC contributes to candidate matching
- [ ] No routing, lookup or matching behaviour fails or changes when NIC is absent

## Blocked by

- #4

