# A Patient row is a registration record, not a person

**Status:** accepted

`hospital_id` has no unique constraint, `nic` and `dob` are null in most rows, and
`age` is free text such as `"30Y"`. Nothing in the ~223,000 rows migrated from the
legacy dBASE system reliably identifies a human being, and the import performed no
deduplication. We therefore treat a `Patient` row as **one registration event**, and
we do not model a `Person` at all: there is no person table, no identity resolution
over existing rows, and no merge operation anywhere in the system.

## Why not deduplicate

A future reader will look at 223,000 unconstrained rows and assume deduplication was
overlooked, so: it was considered and deliberately rejected.

The only available matching signals are transliterated free-text names (the same man
appears as `A.GHAFAR`, `ABDUL GHAFFAR`, `A. GHAFOOR`), a mostly-null NIC, and an
address that changes. Any automated matcher on that data produces false merges, and a
false merge writes one patient's psychiatric history into another patient's file —
clinically dangerous and near-undetectable once done. **False splits are recoverable;
false merges are not.** Merging would also require a clinician reviewing every pair,
which is not available for a dataset this size.

## What we do instead

Duplicates are **prevented at the point of entry, never resolved retrospectively**:

- Before creating a new Patient record, the app searches for likely existing ones and
  shows them. Matches are **suggestions only** — the system advises, the human decides.
  **Nothing anywhere blocks or refuses**: with no reliable identifier, any block would
  be a block on a guess, and blocking a busy registration desk on a guess produces
  workarounds (a misspelled name, a skipped field) that damage the data further.
- **Nothing is ever merged automatically**, and the existing rows are left as they are.
- The durable fix is procedural, not algorithmic: patients keep hold of their
  **Hospital ID**, and a patient who returns with their number never becomes a
  duplicate. New records are therefore issued a **system-generated Hospital ID** in a
  format that cannot collide with legacy values, unique among new records — the legacy
  rows, with their reused and missing numbers, are left untouched. Records without a
  Hospital ID are acceptable and simply aren't findable by ID.
- **NIC is captured but never required** on new registrations. Requiring it would be
  wrong for this population in particular — admissions include minors, people brought
  in by others, and patients arriving in crisis with no documents — and a mandatory
  field of that kind gets filled with `0000000000000` to get past it. Optional capture
  lets coverage improve slowly over the years at no cost.

**NIC is explicitly not the mechanism.** An earlier version of this decision routed on
an exact NIC match, on the reasoning that it is the only field in the schema that truly
identifies a human. That is structurally true and practically useless: NIC is populated
on **well under 1% of records**, and lower again once malformed values are excluded.
Routing logic built on it would almost never fire while giving everyone the impression
that duplicates were being caught — a failure mode worse than having no check at all.
NIC may be used as a best-effort match when present, but nothing in the system may
depend on it being there, and it is not a fallback for anything.

## Consequence

"The complete history of this human" is a question this system cannot answer, and
staff should not assume the record in front of them is the only one. Accepted
knowingly, in exchange for never merging two people by mistake.
