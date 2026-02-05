---
name: Subscription & Access Control Protocol
description: Standardized protocol for handling Stripe subscriptions and mapping them to LMS roles/access.
---

# Subscription & Access Control Protocol

This skill defines how Stripe payments translate to user permissions within the LMS. It ensures that paying users get the correct role (`parent`, `team-leader`, etc.) and that access is revoked upon cancellation.

## 1. Role-Based Access Control (RBAC)
We map Stripe Products/Prices directly to Internal User Groups.

### Mapping Strategy
Do not hardcode Price IDs if possible. Use Stripe Metadata or a config file.

**Recommended Metadata on Stripe Product:**
- Key: `smeb_role`
- Value: `parent` | `team-leader` | `construction_worker` | `sibling`

**Fallback Config (src/config/subscriptions.ts):**
```typescript
export const SUBSCRIPTION_TIERS = {
  'price_Hk1...': 'parent',
  'price_J2k...': 'team-leader',
};
```

## 2. Subscription Lifecycle

### ✅ Activation (invoice.paid)
When a subscription is created or renewed:
1.  Verify `invoice.payment_succeeded`.
2.  Look up `subscription.items.data[0].price.id`.
3.  Resolve user's target role using the Mapping Strategy.
4.  **Action:** Update `users` table:
    ```typescript
    await supabaseAdmin.from('users').update({ 
      role: newRole, 
      subscription_status: 'active' 
    }).eq('id', userId);
    ```

### ⚠️ Cancellation (customer.subscription.updated)
If `cancel_at_period_end` is true:
1.  **Do NOT revoke access immediately.**
2.  Allow access until `current_period_end`.
3.  **UI:** Show "Access expires on [Date]" in the User Dashboard.

### 🚫 Expiration (customer.subscription.deleted)
When the period actually ends:
1.  **Action:** Downgrade user to `free` or `past_member`.
    ```typescript
    await supabaseAdmin.from('users').update({ 
      role: 'free_user', 
      subscription_status: 'expired' 
    }).eq('id', userId);
    ```

## 3. Webhook Security
1.  **Signature Verification:** ALWAYS verify the Stripe signature in `src/app/api/webhooks/stripe/route.ts`.
2.  **Idempotency:** Webhooks can be sent multiple times. Ensure your `manageSubscriptionStatusChange` function is idempotent (checking existing status before updating).

## 4. Testing Payments
Since we lack automated E2E tests for payments, follow this **Manual Verification Checklist**:
1.  [ ] Use `stripe listen` CLI to forward webhooks to localhost:3000.
2.  [ ] Checkout with test card `4242 4242...`.
3.  [ ] Verify user role updates in Supabase `users` table.
4.  [ ] Cancel subscription in Stripe Dashboard (Test Mode).
5.  [ ] Verify UI shows expiration date.
