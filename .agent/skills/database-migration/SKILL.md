---
name: Database & Migration Protocol
description: Procedures for managing Supabase database changes, ensuring production stability, and preventing schema drift.
---

# 🗄️ Database & Migration Protocol

This protocol outlines the rules for changing the database schema and managing Supabase migrations for the LMS - Kursportal.

## 1. Migration Workflow (Supabase)

### Creating Changes
**NEVER** use the Supabase Dashboard UI to make schema changes in production properly. Always use migrations.

1.  **Local Development**: Make changes in your local Supabase Studio or via SQL.
2.  **Generate Migration**:
    ```bash
    supabase db diff --use-migra -f name_of_change
    ```
    *Naming Convention*: `descriptive_snake_case` (e.g., `add_users_table`, `update_rls_policies`).

3.  **Review SQL**: Inspect the generated file in `supabase/migrations/`. 
    *   *Check*: Does it drop columns? (Data loss risk)
    *   *Check*: Does it include RLS policies?
    *   *Check*: Are indexes included for foreign keys?

4.  **Apply Locally**: 
    ```bash
    supabase db reset` (or `supabase migration up` if preserving data)
    ```

## 2. RLS & Security (Database Layer)

*   **Enable RLS**: `ALTER TABLE "public"."table_name" ENABLE ROW LEVEL SECURITY;` must be present for every table.
*   **Performance**: Avoid complex joins in RLS policies. Use redundant columns or `auth.jwt()` claims if possible to reduce policy cost.
*   **Grants**: Explicitly grant permissions to `authenticated` and `anon` roles. Do not rely on defaults.
    ```sql
    GRANT SELECT, INSERT ON TABLE "public"."table_name" TO "authenticated";
    ```

## 3. Seeding & Test Data

*   **Seed File**: Maintain `supabase/seed.sql` for local development data.
*   **Idempotency**: Seed scripts should handle conflict resolution `ON CONFLICT DO NOTHING` to avoid duplicate key errors on resets.
*   **Sensitive Data**: NEVER commit real user data or production secrets to `seed.sql`. Use Faker-generated data.

## 4. Production Deployment

*   **CI/CD**: Migrations are applied automatically via GitHub Actions (if configured) or manually via CLI.
*   **Backup**: Before applying a major migration to production, ensure a Point-in-Time Recovery (PITR) point is available.
*   **Drift Detection**: If `supabase db diff` shows unexpected changes from remote, investigate "schema drift" immediately.

## 5. Enum & Type Management

*   **Database Enums**: Use Postgres ENUMs for static sets (e.g., user roles, status).
*   **TypeScript Sync**: Run `supabase gen types typescript --local > src/types/supabase.ts` after every migration to keep frontend types in sync.

## 6. Migration Checklist

- [ ] Migration file created with descriptive name?
- [ ] RLS policies enabled/updated?
- [ ] Permissions (GRANT) granted?
- [ ] Types generated and committed (`src/types/supabase.ts`)?
- [ ] Verified local rollback/reset works?
