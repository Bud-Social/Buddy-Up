import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  CheckCircle, Fingerprint, Loader, LogOut, Pencil, Smartphone, XCircle, X,
} from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { authApi } from '@/api';
import type { PasskeyInfo } from '@/api/auth';
import { PasskeyCard, RecoveryCodesCard } from '@/components/settings/SecurityExtras';
import { SectionShell } from './SectionShell';

interface DeviceSession {
  id: string;
  device_name: string;
  ip_address: string;
  location: string;
  last_active: string;
  created_at: string;
  is_current: boolean;
}

/** Passkey management: list existing credentials, rename inline, revoke with
 * a password (or TOTP) re-auth challenge. */
function PasskeysList() {
  const { toast } = useToast();
  const [passkeys, setPasskeys] = useState<PasskeyInfo[]>([]);
  const [loading, setLoading] = useState(true);
  const [renamingId, setRenamingId] = useState<number | null>(null);
  const [renameValue, setRenameValue] = useState('');
  const [revoking, setRevoking] = useState<PasskeyInfo | null>(null);
  const [proof, setProof] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(() => {
    setLoading(true);
    authApi.listPasskeys()
      .then((res) => setPasskeys(res.data || []))
      .catch(() => setPasskeys([]))
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  const active = passkeys.filter((p) => !p.revoked_at);

  const submitRename = async (id: number) => {
    const device_name = renameValue.trim();
    if (!device_name) return;
    setBusy(true);
    try {
      const res = await authApi.renamePasskey(id, device_name);
      setPasskeys((ps) => ps.map((p) => (p.id === id ? { ...p, device_name: res.data.device_name } : p)));
      setRenamingId(null);
      toast('success', 'Passkey renamed');
    } catch (err: unknown) {
      toast('error', (err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Rename failed');
    } finally {
      setBusy(false);
    }
  };

  const submitRevoke = async () => {
    if (!revoking || !proof.trim()) return;
    setBusy(true);
    setError('');
    try {
      const isTotpCode = /^\d{6}$/.test(proof.trim());
      await authApi.revokePasskey(revoking.id, isTotpCode ? { code: proof.trim() } : { password: proof });
      toast('success', 'Passkey revoked');
      setRevoking(null);
      setProof('');
      load();
    } catch (err: unknown) {
      setError((err as { response?: { data?: { message?: string } } })?.response?.data?.message || 'Re-authentication failed.');
    } finally {
      setBusy(false);
    }
  };

  return (
    <Card className="p-4">
      <PasskeyCard onRegistered={load} />
      {loading ? (
        <Loader size={20} className="animate-spin text-buddy-text-secondary mx-auto mt-4" />
      ) : active.length > 0 ? (
        <div className="mt-4 space-y-3 border-t border-buddy-surface-raised pt-4">
          <p className="text-sm font-medium">Your passkeys</p>
          {active.map((p) => (
            <div key={p.id} className="flex items-center justify-between gap-2 text-sm">
              <div className="min-w-0">
                {renamingId === p.id ? (
                  <div className="flex items-center gap-2">
                    <Input value={renameValue} onChange={(e) => setRenameValue(e.target.value)} placeholder="Device name" className="!min-h-0 py-1 text-sm" />
                    <Button size="sm" variant="ghost" onClick={() => submitRename(p.id)} isLoading={busy} disabled={!renameValue.trim()}>Save</Button>
                    <Button size="sm" variant="ghost" onClick={() => { setRenamingId(null); setRenameValue(''); }} aria-label="Cancel rename"><X size={14} /></Button>
                  </div>
                ) : (
                  <>
                    <p className="truncate flex items-center gap-1.5"><Fingerprint size={13} className="text-buddy-green flex-shrink-0" />{p.device_name}</p>
                    <p className="text-xs text-buddy-text-secondary">Added {new Date(p.created_at).toLocaleDateString()}</p>
                  </>
                )}
              </div>
              {renamingId !== p.id && (
                <div className="flex items-center gap-1 flex-shrink-0">
                  <Button size="sm" variant="ghost" aria-label={`Rename ${p.device_name}`} onClick={() => { setRenamingId(p.id); setRenameValue(p.device_name); }}>
                    <Pencil size={14} />
                  </Button>
                  <Button size="sm" variant="ghost" className="text-buddy-red" onClick={() => { setRevoking(p); setProof(''); setError(''); }}>Revoke</Button>
                </div>
              )}
            </div>
          ))}
        </div>
      ) : !loading ? (
        <p className="text-xs text-buddy-text-secondary mt-4">No passkeys registered yet.</p>
      ) : null}

      {revoking && (
        <div className="mt-4 space-y-2 border-t border-buddy-surface-raised pt-4" role="dialog" aria-label="Revoke passkey">
          <p className="text-xs text-buddy-text-secondary">
            Confirm your password (or a 6-digit 2FA code) to revoke <strong>{revoking.device_name}</strong>:
          </p>
          <Input type="password" value={proof} onChange={(e) => setProof(e.target.value)} placeholder="Current password or 2FA code" />
          {error && <p className="text-xs text-buddy-red">{error}</p>}
          <div className="flex gap-2">
            <Button size="sm" variant="ghost" onClick={() => { setRevoking(null); setProof(''); setError(''); }}>Cancel</Button>
            <Button size="sm" variant="destructive" onClick={submitRevoke} isLoading={busy} disabled={!proof.trim()}>Confirm Revoke</Button>
          </div>
        </div>
      )}
    </Card>
  );
}

export default function Security() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const user = useAuthStore((s) => s.user);
  const setUser = useAuthStore((s) => s.setUser);

  const totpEnabled = user?.totp_enabled ?? false;

  const [totpDisableOpen, setTotpDisableOpen] = useState(false);
  const [totpDisablePassword, setTotpDisablePassword] = useState('');
  const [totpDisableError, setTotpDisableError] = useState('');
  const [isDisablingTotp, setIsDisablingTotp] = useState(false);

  const [sessions, setSessions] = useState<DeviceSession[]>([]);
  const [sessionsLoading, setSessionsLoading] = useState(true);
  const [revokingId, setRevokingId] = useState<string | null>(null);
  const [logoutAllLoading, setLogoutAllLoading] = useState(false);

  const loadSessions = useCallback(() => {
    setSessionsLoading(true);
    authApi.getSessions()
      .then((res) => setSessions(res.data || []))
      .catch(() => setSessions([]))
      .finally(() => setSessionsLoading(false));
  }, []);

  useEffect(() => { loadSessions(); }, [loadSessions]);

  const handleDisableTotp = async () => {
    setTotpDisableError('');
    setIsDisablingTotp(true);
    try {
      await authApi.disableTotp(totpDisablePassword);
      if (user) setUser({ ...user, totp_enabled: false }, useAuthStore.getState().profile!);
      setTotpDisableOpen(false);
      setTotpDisablePassword('');
      toast('success', '2FA disabled');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setTotpDisableError(data?.message || 'Failed to disable 2FA.');
    } finally {
      setIsDisablingTotp(false);
    }
  };

  const handleRevokeSession = async (id: string) => {
    setRevokingId(id);
    try {
      await authApi.revokeSession(id);
      setSessions((ss) => ss.filter((s) => s.id !== id));
      toast('success', 'Session revoked');
    } catch {
      toast('error', 'Failed to revoke session');
    } finally {
      setRevokingId(null);
    }
  };

  const handleLogoutAll = async () => {
    setLogoutAllLoading(true);
    try {
      await authApi.logoutAllSessions();
      setSessions([]);
      toast('success', 'Signed out of all devices');
    } catch {
      toast('error', 'Failed to sign out other devices');
    } finally {
      setLogoutAllLoading(false);
    }
  };

  return (
    <SectionShell title="Security">
      <div className="space-y-4">
        <PasskeysList />
        {totpEnabled && <RecoveryCodesCard />}

        <Card className="p-4">
          <div className="flex items-start gap-3">
            <Smartphone size={20} className="text-buddy-green mt-0.5" />
            <div className="flex-1">
              <p className="text-sm font-medium">Two-Factor Authentication</p>
              <p className="text-xs text-buddy-text-secondary mt-0.5">
                {totpEnabled ? 'Your account is protected with an authenticator app.' : 'Add an extra layer of security to your account.'}
              </p>
              <div className="flex items-center gap-2 mt-2">
                {totpEnabled ? (
                  <><CheckCircle size={14} className="text-buddy-green" /><span className="text-xs text-buddy-green font-medium">Enabled</span></>
                ) : (
                  <><XCircle size={14} className="text-buddy-text-secondary" /><span className="text-xs text-buddy-text-secondary">Disabled</span></>
                )}
              </div>
            </div>
          </div>
          <div className="mt-3 space-y-2">
            {totpEnabled ? (
              <>
                {!totpDisableOpen && (
                  <Button variant="ghost" size="sm" className="text-buddy-red" onClick={() => { setTotpDisableOpen(true); setTotpDisableError(''); }}>Disable 2FA</Button>
                )}
                {totpDisableOpen && (
                  <div className="space-y-2 pt-2 border-t border-buddy-surface-raised">
                    <p className="text-xs text-buddy-text-secondary">Enter your password to disable 2FA:</p>
                    <Input type="password" value={totpDisablePassword} onChange={(e) => setTotpDisablePassword(e.target.value)} placeholder="Current password" />
                    {totpDisableError && <p className="text-xs text-buddy-red">{totpDisableError}</p>}
                    <div className="flex gap-2">
                      <Button size="sm" variant="ghost" onClick={() => { setTotpDisableOpen(false); setTotpDisablePassword(''); setTotpDisableError(''); }}>Cancel</Button>
                      <Button size="sm" variant="destructive" onClick={handleDisableTotp} isLoading={isDisablingTotp} disabled={!totpDisablePassword}>Confirm Disable</Button>
                    </div>
                  </div>
                )}
              </>
            ) : (
              <Button variant="outline" size="sm" onClick={() => navigate('/totp-setup')}><Smartphone size={14} className="mr-1" /> Enable 2FA</Button>
            )}
          </div>
        </Card>

        <Card className="p-4">
          <p className="text-sm font-medium mb-3">Active Sessions</p>
          {sessionsLoading ? (
            <Loader size={20} className="animate-spin text-buddy-text-secondary mx-auto" />
          ) : sessions.length === 0 ? (
            <p className="text-xs text-buddy-text-secondary">No active sessions found.</p>
          ) : (
            <div className="space-y-3">
              {sessions.map((s) => (
                <div key={s.id} className="flex items-center justify-between gap-2 text-sm">
                  <div className="min-w-0">
                    <p className="truncate">
                      {s.device_name || 'Unknown device'}
                      {s.is_current && <span className="ml-2 text-[10px] text-buddy-green bg-buddy-green/10 px-1.5 py-0.5 rounded-full">This device</span>}
                    </p>
                    <p className="text-xs text-buddy-text-secondary truncate">
                      {s.location || s.ip_address || 'Unknown location'} · {new Date(s.last_active).toLocaleString()}
                    </p>
                  </div>
                  {s.is_current ? (
                    <span className="text-xs text-buddy-green flex-shrink-0">Active now</span>
                  ) : (
                    <Button size="sm" variant="ghost" className="text-buddy-red flex-shrink-0" isLoading={revokingId === s.id} onClick={() => handleRevokeSession(s.id)}>
                      Revoke
                    </Button>
                  )}
                </div>
              ))}
            </div>
          )}
        </Card>

        <Button variant="destructive" className="w-full" size="sm" onClick={handleLogoutAll} isLoading={logoutAllLoading}>
          <LogOut size={14} className="mr-1" /> Sign Out All Devices
        </Button>
      </div>
    </SectionShell>
  );
}
