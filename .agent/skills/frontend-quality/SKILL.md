---
name: Frontend Quality & Accessibility Protocol
description: Standardized checklist and procedures for ensuring frontend quality, accessibility (WCAG 2.1 AA), and performance.
---

# ✅ Frontend Quality & Accessibility Protocol

This protocol defines the ongoing standards for reviewing and implementing frontend components in the LMS - Kursportal.

## 1. Accessibility (a11y) - WCAG 2.1 AA

*   **Semantic HTML**: Use `<button>`, `<nav>`, `<main>`, `<article>`, `<header>`, `<footer>` appropriately. Avoid `div` soup.
*   **Keyboard Navigation**:
    *   Ensure all interactive elements are focusable (`tabindex="0"` if not native).
    *   Verify visible focus states (standardized via `focus-visible:ring`).
    *   No "keyboard traps" in modals or menus.
*   **Screen Readers**:
    *   `aria-label` for icon-only buttons.
    *   `aria-expanded`/`aria-controls` for accordions and menus.
    *   `alt` text for ALL images (empty `alt=""` for decorative).
*   **Color Contrast**: Ensure text has sufficient contrast ratio (4.5:1 normal, 3:1 large) against background. Use the defined semantic colors (`text.primary`, `bg.surface`).

## 2. Performance & Core Web Vitals

*   **Images**: Always use `next/image` with proper `width`/`height` or `fill` to prevent Layout Shift (CLS).
*   **Lazy Loading**:
    *   Lazy load heavy components (charts, maps, rich text editors) using `next/dynamic`.
    *   Lazy load below-the-fold content.
*   **Bundle Size**: Import icons individually (e.g., `import { User } from 'lucide-react'`) to enable tree-shaking.
*   **Fonts**: Use `next/font` to prevent FOUT (Flash of Unstyled Text) and optimize loading.

## 3. Component Architecture (Neo-Brutalist)

*   **Design Tokens**: Use `tailwind` classes defined in the design system skill (e.g., `border-3`, `shadow-hard`).
*   **Reusable Components**: Don't duplicate UI logic. Extract common patterns (Cards, Modals, Buttons) to `src/components/ui`.
*   **Mobile-First**: Design for mobile dimensions first, then add `md:` and `lg:` breakpoints.

## 4. Internationalization (i18n)

*   **No Hardcoded Strings**: All user-facing text MUST reside in `src/messages/{locale}.json`.
*   **Dynamic Values**: support parameterized translations (e.g., "Hello {name}").
*   **RTL Support**: Keep layout flexible for future RTL addition (start/end instead of left/right for margins/padding where relevant, via logical properties or Tailwind `s-` / `e-`).

## 5. Pre-Merge Checklist

- [ ] navigating the feature using ONLY the keyboard works?
- [ ] Screen reader announces meaningful labels for buttons?
- [ ] No `console.error` warnings in devtools?
- [ ] `next/image` used for assets?
- [ ] All text is translatable (via `t()`)?
- [ ] Mobile view verified in Chrome DevTools responsive mode?
