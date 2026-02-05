---
name: Zero-Knowledge Implementation Protocol
description: Standardized security protocol for implementing client-side Zero-Knowledge encryption features.
---

# Zero-Knowledge (ZK) Implementation Protocol

This project guarantees that sensitive user data (Journal, Self-Assessment) is **never** accessible to the server or admins. This skill defines the mandatory cryptographic standards.

## 1. Core Principles
1.  **Client-Side Only:** Encryption and decryption MUST happen in the browser using the Web Crypto API.
2.  **No Key Storage:** The encryption key is derived from the user's password/passphrase. We NEVER store the raw key or the password on the server.
3.  **Ephemeral Access:** If the user forgets their password, the data is lost forever. There is no "Forgot Password" for ZK data.

## 2. Cryptographic Primitives (src/utils/crypto.ts)

### Key Derivation (PBKDF2)
We derive a symmetric key from the user's input.
- **Algorithm:** `PBKDF2`
- **Hash:** `SHA-256`
- **Iterations:** `100,000` (Minimum)
- **Salt:** MUST be unique per user.
  - **Format:** `PREFIX + userId` (e.g., `COURSE_HUB_JOURNAL_v2_user123`)
  - *Why?* Prevents rainbow table attacks across users.

### Encryption (AES-GCM)
- **Algorithm:** `AES-GCM`
- **Key Length:** `256-bit`
- **IV (Initialization Vector):** 96-bit (12 bytes), generated randomly **per entry**.
  - *Critical:* Never reuse an IV with the same key.

## 3. Implementation Checklist

### Writing Data (Encryption)
1.  [ ] Get `passphrase` from user input (or memory cache).
2.  [ ] Derive `CryptoKey` using `deriveKey(passphrase, userId)`.
3.  [ ] Encrypt content: `encryptJournalEntry(content, key)`.
4.  [ ] Send **only** `ciphertext` and `iv` to Supabase.
    -   *Database columns:* `content (text)`, `iv (text)` (both Base64).

### Reading Data (Decryption)
1.  [ ] Fetch `ciphertext` and `iv` from Supabase.
2.  [ ] Get `passphrase` from user input (or memory cache).
3.  [ ] Derive `CryptoKey` using `deriveKey(passphrase, userId)`.
4.  [ ] Decrypt: `decryptJournalEntry(ciphertext, iv, key)`.
5.  [ ] Handle failure: If decryption fails, the password is wrong.

## 4. Security Rules (DO NOT BREAK)
-   🚫 **NEVER** save the `passphrase` or `CryptoKey` in `localStorage` or `cookies`. (SessionStorage or React State IS allowed for UX).
-   🚫 **NEVER** send the `passphrase` to an API endpoint (except `/auth/login` for initial auth, but ZK keys should ideally be separate).
-   ✅ **ALWAYS** handle empty states gracefully (e.g., if decryption fails, show "Locked" or prompt for password).

## 5. Code Snippet (Usage)
```typescript
import { deriveKey, encryptJournalEntry } from '@/utils/crypto';

// 1. Derive Key
const key = await deriveKey(userPassword, userId);

// 2. Encrypt
const { ciphertext, iv } = await encryptJournalEntry(diaryText, key);

// 3. Save
await supabase.from('journal').insert({ 
  content: ciphertext, 
  iv: iv,
  user_id: userId 
});
```
