/**
 * crypto.ts — Transport-layer E2EE helper using Web Crypto API (ECDH + AES-GCM).
 *
 * Each device generates an ECDH key pair stored in IndexedDB.
 * A shared AES-GCM key is derived via ECDH for each conversation partner.
 * Messages are encrypted before sending and decrypted on receipt.
 *
 * This provides end-to-end encryption where the server only sees ciphertext.
 */

const DB_NAME = 'buddyup_crypto';
const KEY_STORE = 'keys';
const ECDH_PARAMS: EcKeyGenParams = { name: 'ECDH', namedCurve: 'P-256' };
const AES_PARAMS = { name: 'AES-GCM', length: 256 };

// ---------- Persistent key storage via IndexedDB ----------

function openDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, 1);
    req.onupgradeneeded = () => req.result.createObjectStore(KEY_STORE);
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function dbGet<T>(key: string): Promise<T | undefined> {
  const db = await openDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(KEY_STORE, 'readonly');
    const req = tx.objectStore(KEY_STORE).get(key);
    req.onsuccess = () => resolve(req.result as T);
    req.onerror = () => reject(req.error);
  });
}

async function dbSet(key: string, value: unknown): Promise<void> {
  const db = await openDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(KEY_STORE, 'readwrite');
    tx.objectStore(KEY_STORE).put(value, key);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
  });
}

// ---------- Key pair management ----------

export interface ExportedPublicKey {
  x: string; // base64url-encoded x coordinate
  y: string;
  crv: 'P-256';
  kty: 'EC';
}

async function getOrCreateKeyPair(): Promise<CryptoKeyPair> {
  const existing = await dbGet<CryptoKeyPair>('myKeyPair');
  if (existing) return existing;

  const kp = await crypto.subtle.generateKey(ECDH_PARAMS, false, ['deriveKey', 'deriveBits']);
  await dbSet('myKeyPair', kp);
  return kp;
}

export async function getMyPublicKeyJWK(): Promise<ExportedPublicKey> {
  const kp = await getOrCreateKeyPair();
  const jwk = await crypto.subtle.exportKey('jwk', kp.publicKey);
  return { x: jwk.x!, y: jwk.y!, crv: 'P-256', kty: 'EC' };
}

// ---------- Derive shared AES key for a conversation partner ----------

const _sharedKeyCache = new Map<string, CryptoKey>();

export async function deriveSharedKey(theirPublicJWK: ExportedPublicKey, partnerId: string): Promise<CryptoKey> {
  if (_sharedKeyCache.has(partnerId)) return _sharedKeyCache.get(partnerId)!;

  const kp = await getOrCreateKeyPair();
  const theirKey = await crypto.subtle.importKey(
    'jwk',
    { ...theirPublicJWK, key_ops: [], ext: true },
    ECDH_PARAMS,
    false,
    [],
  );
  const aesKey = await crypto.subtle.deriveKey(
    { name: 'ECDH', public: theirKey },
    kp.privateKey,
    AES_PARAMS,
    false,
    ['encrypt', 'decrypt'],
  );
  _sharedKeyCache.set(partnerId, aesKey);
  return aesKey;
}

// ---------- Encrypt / Decrypt ----------

export async function encryptMessage(plaintext: string, sharedKey: CryptoKey): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encoded = new TextEncoder().encode(plaintext);
  const ciphertext = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, sharedKey, encoded);
  // Pack: iv (12 bytes) + ciphertext — encode as base64
  const combined = new Uint8Array(iv.byteLength + ciphertext.byteLength);
  combined.set(iv, 0);
  combined.set(new Uint8Array(ciphertext), iv.byteLength);
  return btoa(String.fromCharCode(...combined));
}

export async function decryptMessage(cipherB64: string, sharedKey: CryptoKey): Promise<string> {
  try {
    const bytes = Uint8Array.from(atob(cipherB64), (c) => c.charCodeAt(0));
    const iv = bytes.slice(0, 12);
    const data = bytes.slice(12);
    const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, sharedKey, data);
    return new TextDecoder().decode(plaintext);
  } catch {
    // If decryption fails (e.g. no shared key yet), return as-is (unencrypted fallback)
    return cipherB64;
  }
}
