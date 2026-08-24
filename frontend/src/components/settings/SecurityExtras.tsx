/**
 * SecurityExtras – passkey (WebAuthn) registration and recovery-code
 * management for Settings → Security. Recovery codes are returned by the
 * server exactly once, when 2FA is enabled or explicitly regenerated.
 */
import { useState } from 'react';
import { Fingerprint, KeyRound, Loader } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { apiClient } from '@/api/client';
import type { ApiResponse } from '@/types';

function bufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let bin = '';
  bytes.forEach(b => { bin += String.fromCharCode(b); });
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function base64UrlToBuffer(value: string): Uint8Array<ArrayBuffer> {
  const padded = value + '='.repeat((4 - (value.length % 4)) % 4);
  const bin = atob(padded.replace(/-/g, '+').replace(/_/g, '/'));
  const buffer = new ArrayBuffer(bin.length);
  const bytes = new Uint8Array(buffer);
  for (let i = 0; i < bin.length; i += 1) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

export function PasskeyCard() {
  const { toast } = useToast();
  const [busy, setBusy] = useState(false);

  const supported = typeof window !== 'undefined' && window.PublicKeyCredential;

  const handleRegister = async () => {
    if (!supported) {
      toast('error', 'This browser does not support passkeys.');
      return;
    }
    setBusy(true);
    try {
      const begin = await apiClient.post<ApiResponse<{ options: Record<string, unknown> }>>(
        '/auth/passkeys/register/begin/',
        {},
      );
      const opts = begin.data.data!.options as {
        publicKey: {
          challenge: string;
          user: { id: string };
          excludeCredentials?: Array<{ id: string }>;
        };
      };
      // The server serialises via options_to_json → nested under `publicKey`.
      const pk = (opts.publicKey ?? opts) as {
        challenge: string;
        user: { id: string; name?: string; displayName?: string };
        rp?: Record<string, unknown>;
        pubKeyCredParams?: unknown;
        timeout?: number;
        excludeCredentials?: Array<{ id: string; transports?: string[] }>;
        authenticatorSelection?: unknown;
        attestation?: string;
      };
      const createOptions = {
        challenge: base64UrlToBuffer(pk.challenge),
        rp: pk.rp,
        user: {
          ...(pk.user as unknown as Record<string, unknown>),
          id: base64UrlToBuffer(pk.user.id),
        },
        pubKeyCredParams: pk.pubKeyCredParams,
        timeout: pk.timeout,
        excludeCredentials: pk.excludeCredentials?.map(c => ({
          ...c,
          id: base64UrlToBuffer(c.id),
          transports: c.transports,
        })),
        authenticatorSelection: pk.authenticatorSelection,
        attestation: pk.attestation,
      } as unknown as PublicKeyCredentialCreationOptions;
      const createCred = await navigator.credentials.create({
        publicKey: createOptions,
      }) as PublicKeyCredential | null;
      if (!createCred) throw new Error('No credential created');

      const response = createCred.response as AuthenticatorAttestationResponse;
      await apiClient.post<ApiResponse<{ registered: boolean }>>(
        '/auth/passkeys/register/finish/',
        {
          device_name: navigator.platform || 'This device',
          credential: {
            id: createCred.id,
            rawId: bufferToBase64Url(createCred.rawId),
            type: createCred.type,
            response: {
              attestationObject: bufferToBase64Url(response.attestationObject),
              clientDataJSON: bufferToBase64Url(response.clientDataJSON),
            },
          },
        },
      );
      toast('success', 'Passkey registered — you can now sign in with biometrics.');
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } }; message?: string })?.response?.data?.message
        || (err as Error)?.message
        || 'Passkey registration failed';
      toast('error', msg);
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card className="p-4">
      <div className="flex items-start gap-3">
        <Fingerprint size={20} className="text-buddy-green mt-0.5" />
        <div className="flex-1">
          <p className="text-sm font-medium">Passkeys &amp; Biometrics</p>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Sign in with your fingerprint, face, or device lock — no password needed.
          </p>
          <Button size="sm" variant="outline" className="mt-2" onClick={handleRegister} disabled={busy}>
            {busy ? <Loader size={14} className="animate-spin" /> : null}
            Add a passkey to this device
          </Button>
        </div>
      </div>
    </Card>
  );
}

export function RecoveryCodesCard() {
  const { toast } = useToast();
  const [code, setCode] = useState('');
  const [codes, setCodes] = useState<string[] | null>(null);
  const [busy, setBusy] = useState(false);

  const regenerate = async () => {
    setBusy(true);
    try {
      const res = await apiClient.post<ApiResponse<{ recovery_codes: string[] }>>(
        '/auth/recovery-codes/regenerate/',
        { code },
      );
      setCodes(res.data.data!.recovery_codes);
      setCode('');
      toast('success', 'New recovery codes generated.');
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Failed';
      toast('error', msg);
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card className="p-4">
      <div className="flex items-start gap-3">
        <KeyRound size={20} className="text-buddy-green mt-0.5" />
        <div className="flex-1">
          <p className="text-sm font-medium">Recovery Codes</p>
          <p className="text-xs text-buddy-text-secondary mt-0.5">
            Single-use backup codes in case you lose your authenticator.
          </p>
          {codes ? (
            <div className="mt-2 p-3 rounded-xl bg-buddy-surface-raised font-mono text-xs grid grid-cols-2 gap-y-1 max-w-xs select-all">
              {codes.map(c => <span key={c}>{c}</span>)}
            </div>
          ) : (
            <div className="flex items-center gap-2 mt-2 max-w-xs">
              <Input
                placeholder="Authenticator code"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                inputMode="numeric"
                maxLength={6}
              />
              <Button size="sm" variant="outline" onClick={regenerate} disabled={busy || code.length !== 6}>
                {busy ? <Loader size={14} className="animate-spin" /> : null}
                Generate new codes
              </Button>
            </div>
          )}
        </div>
      </div>
    </Card>
  );
}
