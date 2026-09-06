# 06: Search-first registration: candidate lookup

**Tracker:** GitHub issue #9 — https://github.com/roshaankhan10/Naya-Zehan---Patient-Database-Application/issues/9

**Status:** ready-for-agent

> Snapshot of the GitHub issue at time of publication. GitHub is the source of truth;
> re-read the issue before starting work in case it has been edited or closed.

## Parent

#2 — Duplicate prevention: generated Hospital IDs and search-first registration

## What to build

When staff begin registering a patient, the app shows likely existing Patient records as they type, so the person at the desk sees an existing record before creating another one.

This is advice, not enforcement. Staff can always proceed to create a new record, the system never refuses, and nothing is ever merged automatically. With no reliable identifier in this data, any block would be a block on a guess — and blocking a busy registration desk on a guess produces workarounds (a misspelled name, a skipped field) that damage the data more than the duplicate would have.

Candidate lookup reuses the existing patient search rather than introducing a parallel matching endpoint. Matching is on name together with father's name, tolerant of the spelling variation inherent in transliterated names, returning a small ranked set with enough detail to tell candidates apart.

Opening a suggested record continues with that record instead of starting again.

## Acceptance criteria

- [ ] Typing a patient's details during registration surfaces similar existing Patient records
- [ ] Matching considers name together with father's name, not name alone
- [ ] A near-matching name with different spelling still surfaces the existing record
- [ ] An unrelated name surfaces nothing, so an empty result is a clear signal to proceed
- [ ] Results are a small, ranked set showing enough detail to distinguish similar patients
- [ ] A suggested record can be opened directly from the registration screen
- [ ] Creating a new Patient record succeeds normally even when candidates are shown
- [ ] Nothing blocks, refuses, or requires a confirmation checkbox
- [ ] No merge operation is introduced anywhere
- [ ] Suggestions appear fast enough not to slow registration

## Blocked by

- #4

