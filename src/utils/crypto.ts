/**
 * Client-side encryption utilities using Web Crypto API.
 * 
 * Strategy:
 * 1. User provides a Passphrase.
 * 2. We derive a symmetric Key (AES-GCM) from the Passphrase using PBKDF2.
 *    Salt is now user-specific (userId + app prefix) for better security isolation.
 * 3. We Encrypt content -> Ciphertext + IV.
 * 4. We Decrypt content <- Ciphertext + IV + Key.
 */

const SALT_PREFIX = "COURSE_HUB_JOURNAL_v2_"; // Prefix combined with userId for per-user salt

// Convert string to buffer
const str2ab = (str: string) => new TextEncoder().encode(str);
const ab2str = (buf: ArrayBuffer) => new TextDecoder().decode(buf);

// Base64 helpers
const arrayBufferToBase64 = (buffer: ArrayBuffer) => {
    let binary = '';
    const bytes = new Uint8Array(buffer);
    const len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
};

const base64ToArrayBuffer = (base64: string) => {
    const binary_string = window.atob(base64);
    const len = binary_string.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
        bytes[i] = binary_string.charCodeAt(i);
    }
    return bytes.buffer;
};

// DERIVE KEY from Passphrase with per-user salt
export async function deriveKey(passphrase: string, userId: string): Promise<CryptoKey> {
    // Create per-user salt by combining prefix with userId
    const userSalt = `${SALT_PREFIX}${userId}`;

    const keyMaterial = await window.crypto.subtle.importKey(
        "raw",
        str2ab(passphrase),
        { name: "PBKDF2" },
        false,
        ["deriveKey"]
    );

    return window.crypto.subtle.deriveKey(
        {
            name: "PBKDF2",
            salt: str2ab(userSalt),
            iterations: 100000,
            hash: "SHA-256"
        },
        keyMaterial,
        { name: "AES-GCM", length: 256 },
        false,
        ["encrypt", "decrypt"]
    );
}

// ENCRYPT
export async function encryptJournalEntry(content: string, key: CryptoKey): Promise<{ ciphertext: string; iv: string }> {
    const iv = window.crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV
    const encodedContent = str2ab(content);

    const encryptedContent = await window.crypto.subtle.encrypt(
        {
            name: "AES-GCM",
            iv: iv
        },
        key,
        encodedContent
    );

    return {
        ciphertext: arrayBufferToBase64(encryptedContent),
        iv: arrayBufferToBase64(iv.buffer)
    };
}

// DECRYPT
export async function decryptJournalEntry(ciphertext: string, ivStr: string, key: CryptoKey): Promise<string> {
    const iv = base64ToArrayBuffer(ivStr);
    const encryptedData = base64ToArrayBuffer(ciphertext);

    try {
        const decryptedContent = await window.crypto.subtle.decrypt(
            {
                name: "AES-GCM",
                iv: new Uint8Array(iv)
            },
            key,
            encryptedData
        );
        return ab2str(decryptedContent);
    } catch (e) {
        console.error("Decryption failed:", e);
        throw new Error("Failed to decrypt. Wrong Key?");
    }
}
