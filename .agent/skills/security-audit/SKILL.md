---
name: Security & Audit Protocol
description: Standardized checklist and procedures for ensuring application security, including RLS policies, input validation, and headers.
---

# 🛡️ Security & Audit Protocol

This protocol defines the mandatory security checks and standards for code changes in the LMS - Kursportal application.

## 1. Authentication & Authorization (AuthZ)

### RLS Policies (Row Level Security)
*   **Mandatory Check**: Every new table MUST have RLS enabled.
*   **Policy Granularity**: Define separate policies for `SELECT`, `INSERT`, `UPDATE`, `DELETE`. Avoid broad `ALL` policies unless strictly necessary.
*   **Helper Functions**: Use `auth.uid()` and `is_admin()` helper (or equivalent) for policy definitions.
*   **Service Key**: Never use the `service_role` key in client-side code.

### Server Actions & API Routes
*   **Authentication Check**: Ensure `getUser` or `getSession` is called at the start of every protected Server Action.
*   **Authorization Check**: Verify user roles (e.g., `role === 'admin'`) *before* executing business logic.
*   **Session Validation**: Don't trust the client. Verify identity on the server.

## 2. Input Validation & sanitization

### Server Actions
*   **Zod Schemas**: Use `zod` to validate ALL input arguments in Server Actions.
*   **Sanitization**: Sanitize HTML content if allowing rich text (use `dompurify` or similar serverside if applicable, typically handled by libraries like `sanitize-html`).
*   **Type Safety**: Ensure strict TypeScript types match the Zod schemas.

### SQL Injection Prevention
*   **Supabase Client**: Always use the Supabase JS client parameterization (e.g., `.eq('id', id)`).
*   **RPC Calls**: If using raw SQL (rare), strictly use parameterized queries.

## 3. Data Protection

### Zero-Knowledge Encryption (AES-256-GCM)
*   User journal entries MUST be encrypted on the client side before submission.
*   Do NOT send the encryption key to the server.
*   Verify `iv` (Initialization Vector) is unique for every entry.

### Sensitive Data
*   **Logs**: Never log PII (Personally Identifiable Information), tokens, or passwords to console/server logs.
*   **Error Messages**: Return generic error messages to the client ("Something went wrong") instead of raw database errors.

## 4. Rate Limiting

*   **Public Endpoints**: Apply rate limiting (e.g., via Middleware or Upstash) to login, registration, and public API feedback forms.
*   **DoS Protection**: Ensure resource-intensive routes (PDF generation, large queries) have strict limits.

## 5. Security Headers

Ensure `next.config.ts` or Middleware sets:
*   `X-Content-Type-Options: nosniff`
*   `X-Frame-Options: DENY` (or `SAMEORIGIN`)
*   `Referrer-Policy: strict-origin-when-cross-origin`
*   `Content-Security-Policy`: Restrict scripts, styles, and images to trusted domains.

## 6. Audit Checklist (Pre-Merge)

- [ ] RLS policies enabled and verified?
- [ ] Server Action inputs validated with Zod without `any`?
- [ ] User role checked on server side?
- [ ] No secrets in client-side bundles?
- [ ] Dependencies updated and audited (`npm audit`)?
