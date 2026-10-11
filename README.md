# livestock-seed

Reference data and (anonymised) development fixtures for the Livestock
Management System. Loaded after migrations by `livestock-infra` (`make seed`).

## Contents

| Path                         | Purpose                                        |
|------------------------------|------------------------------------------------|
| `seed/01_reference_data.sql` | System roles, permissions, breeds, alert rules |
| `seed/02_dev_fixtures.sql`   | Demo tenant + sample records (**dev only**)    |

## Rules

- Reference data is idempotent (`ON CONFLICT DO NOTHING`) and safe to re-run.
- **Never** put real farm data here. This repo is public.
- Fixture passwords use `pgcrypto`'s `crypt(...)`, not committed hashes.

```bash
# from livestock-infra
make seed
```
