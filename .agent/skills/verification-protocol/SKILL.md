---
name: Verification & Localization Protocol
description: Standardized workflow for verifying features across locales (NO/EN) and managing Next.js caching issues.
---

# Verification & Localization Protocol

This skill outlines the mandatory steps to ensure high-quality releases, specifically targeting localization consistency and Next.js caching behaviors.

## 1. Localization Sync Checklist
**CRITICAL:** Never update one language file without the other.

1.  **Dual File Update:** If you edit `src/messages/no.json`, you MUST edit `src/messages/en.json`.
2.  **Key Consistency:** Verify that the nesting structure is identical (e.g., `Home.features.zk_read_more`).
3.  **Missing Keys:** If a key is missing in one language, it will often cause the UI to crash or show the raw key path.

## 2. The "Hard Reset" Protocol
Next.js (especially with `next-intl`) can aggressively cache translation files. If your changes aren't showing:

1.  **Stop Server:** `Ctrl+C` to stop the current dev server.
2.  **Wipe Cache:** Run `rm -rf .next`.
3.  **Restart:** Run `npm run dev` (optionally with `-p <new_port>` if issues persist).

**Turbo Command:**
```bash
rm -rf .next && npm run dev
```

## 3. Browser Verification Template
When using the `browser_subagent` to verify UI changes, ALWAYS use this multi-locale pattern:

> "Verify the [Feature Name] functionality:
> 1. Navigate to `http://localhost:3000/no` and check [Specific Element].
> 2. Switch to `http://localhost:3000/en` and check that [Specific Element] is translated to English.
> 3. Verify that no raw translation keys (e.g., `Footer.pricing`) are visible."

## 4. Visual Regression Checks
- **Overflows:** German/Norwegian words are often longer than English. Check for text wrapping issues.
- **Date Formats:** Ensure dates are formatted according to the locale (DD.MM.YYYY for NO vs defaults).

## 5. Deployment Pre-Flight
Before marking a task as Done:
- [ ] `npm run lint` checked?
- [ ] Both `/no` and `/en` routes manually visited?
- [ ] Console checked for hydration errors?
