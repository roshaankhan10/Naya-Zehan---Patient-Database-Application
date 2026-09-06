# Supabase (PostgreSQL) instead of the proposed Firebase

**Status:** accepted — deviates from the signed proposal

The signed project proposal specifies "designing a NoSQL database (Firebase)". The
implementation instead uses Supabase (managed PostgreSQL) behind a Django REST API.
Patient records are strongly relational — a Patient record has many Admissions, and
the source data is a set of fixed-schema dBASE tables — so a relational store maps
directly onto the data we actually migrated, gives us real foreign keys and
transactional imports, and lets Django's ORM, admin and auth carry most of the
system. Modelling the same data as denormalised document trees in Firebase would have
meant hand-maintaining the patient↔admission relationship in application code.

## Consequences worth stating to the institute

This deviates from a signed document, so it needs to be disclosed rather than
discovered:

- **Hosting region.** The database is hosted on Supabase's free tier on AWS
  `ap-northeast-2` — **Seoul, South Korea**. Approximately 223,000 identified
  psychiatric records of patients of a Hyderabad public institute are stored outside
  Pakistan. Firebase would also have been foreign-hosted, so the *category* of choice
  follows the proposal; the specific region was never put to the institute.
- **Who can technically access the data.** The Supabase project owner, anyone holding
  the database credentials, and Supabase/AWS as infrastructure providers. Patients
  consented to none of this — these are legacy records, many predating the project by
  years.
- **Free-tier limitations** are accepted deliberately; see `docs/decisions-log.md`
  ("Infrastructure").

The institute should be given this in writing. The intent is that they *accept* the
arrangement, not that they find out about it later.
