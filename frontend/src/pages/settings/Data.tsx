import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CheckCircle, Download, Loader, RefreshCw, Trash2, XCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { Modal } from '@/components/ui/Modal';
import { useToast } from '@/components/ui/Toast';
import { useAuthStore } from '@/store/authStore';
import { authApi } from '@/api';
import type { ExportStatus } from '@/api/auth';
import { SectionShell } from './SectionShell';

const DELETE_PHRASE = 'delete my account';

export default function Data() {
  const navigate = useNavigate();
  const { toast } = useToast();
  const logout = useAuthStore((s) => s.logout);

  const [consentStatus, setConsentStatus] = useState<Awaited<ReturnType<typeof authApi.getConsentStatus>>['data'] | null>(null);
  const [consentLoading, setConsentLoading] = useState(true);

  const [exportStatus, setExportStatus] = useState<ExportStatus | null>(null);
  const [isExporting, setIsExporting] = useState(false);
  const [exportMessage, setExportMessage] = useState('');

  const [deactivateOpen, setDeactivateOpen] = useState(false);
  const [isDeactivating, setIsDeactivating] = useState(false);

  const [deleteConfirm, setDeleteConfirm] = useState('');
  const [deletePassword, setDeletePassword] = useState('');
  const [deleteError, setDeleteError] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    let cancelled = false;
    Promise.allSettled([authApi.getConsentStatus(), authApi.exportStatus()])
      .then(([consent, status]) => {
        if (cancelled) return;
        if (consent.status === 'fulfilled') setConsentStatus(consent.value.data);
        if (status.status === 'fulfilled') setExportStatus(status.value.data);
      })
      .finally(() => { if (!cancelled) setConsentLoading(false); });
    return () => { cancelled = true; };
  }, []);

  const refreshExportStatus = () => {
    authApi.exportStatus().then((res) => setExportStatus(res.data)).catch(() => {});
  };

  const handleExport = async () => {
    setIsExporting(true);
    setExportMessage('');
    try {
      await authApi.exportData();
      setExportMessage('Data export requested. We will email you a download link when it is ready.');
      toast('success', 'Export requested');
      refreshExportStatus();
    } catch {
      setExportMessage('Failed to request export. Please try again.');
      toast('error', 'Export failed');
    } finally {
      setIsExporting(false);
    }
  };

  const handleDeactivate = async () => {
    setIsDeactivating(true);
    try {
      await authApi.deactivateAccount();
      toast('success', 'Account deactivated');
      logout();
      navigate('/');
    } catch {
      toast('error', 'Failed to deactivate account');
    } finally {
      setIsDeactivating(false);
    }
  };

  const handleDelete = async () => {
    setDeleteError('');
    if (deleteConfirm !== DELETE_PHRASE || !deletePassword) return;
    setIsDeleting(true);
    try {
      await authApi.deleteAccount(deleteConfirm, deletePassword);
      toast('success', 'Account deleted');
      logout();
      navigate('/');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setDeleteError(data?.message || 'Failed to delete account.');
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <SectionShell title="Your Data">
      <div className="space-y-4">
        <Card className="p-4">
          <p className="text-sm font-medium mb-1">Consent & Policy Versions</p>
          <p className="text-xs text-buddy-text-secondary mb-3">The version of each policy you accepted at registration.</p>
          {consentLoading ? (
            <p className="text-xs text-buddy-text-secondary">Loading consent status…</p>
          ) : consentStatus ? (
            <div className="space-y-1.5">
              {Object.entries(consentStatus.policies).map(([key, p]) => (
                <div key={key} className="flex items-center justify-between gap-3 text-xs">
                  <span className="text-buddy-text-primary capitalize">{key.replace(/_/g, ' ')}</span>
                  <span className="flex items-center gap-2 text-buddy-text-secondary">
                    {p.up_to_date
                      ? <CheckCircle size={13} className="text-buddy-green" />
                      : <XCircle size={13} className="text-buddy-orange" />}
                    v{p.accepted_version || '—'} / current v{p.current_version}
                  </span>
                </div>
              ))}
              {consentStatus.requires_parental_coowner && (
                <p className={`text-xs mt-2 ${consentStatus.guardian_verified ? 'text-buddy-green' : 'text-buddy-orange'}`}>
                  {consentStatus.guardian_verified
                    ? 'Parental co-owner verified.'
                    : 'This account requires parental co-owner verification. Contact support to complete it.'}
                </p>
              )}
            </div>
          ) : (
            <p className="text-xs text-buddy-text-secondary">Could not load consent status.</p>
          )}
        </Card>

        <Card className="p-4">
          <p className="text-sm font-medium mb-1">Export Your Data</p>
          <p className="text-xs text-buddy-text-secondary mb-3">
            Download all your data as a JSON archive. Includes profile, posts, messages, transactions, and sessions.
          </p>
          {exportMessage && <p className="text-xs text-buddy-green mb-2">{exportMessage}</p>}
          {exportStatus && (
            <div className="flex items-center gap-2 text-xs text-buddy-text-secondary mb-3">
              {exportStatus.ready ? (
                <>
                  <CheckCircle size={13} className="text-buddy-green" />
                  <span>
                    Archive ready{exportStatus.filename ? `: ${exportStatus.filename}` : ''}
                    {exportStatus.created_at && ` · ${new Date(exportStatus.created_at).toLocaleString()}`}
                  </span>
                </>
              ) : (
                <>
                  <Loader size={13} className="animate-spin" />
                  <span>Export in progress — we will email you when it is ready.</span>
                </>
              )}
              <button onClick={refreshExportStatus} className="ml-1 text-buddy-green hover:text-buddy-green-deep inline-flex items-center" aria-label="Refresh export status">
                <RefreshCw size={12} />
              </button>
            </div>
          )}
          <Button variant="outline" size="sm" onClick={handleExport} isLoading={isExporting}>
            <Download size={14} className="mr-1" /> Request Export
          </Button>
        </Card>

        <Card className="p-4 border-buddy-orange/30 bg-buddy-orange/5">
          <p className="text-sm font-medium text-buddy-orange">Deactivate Account</p>
          <p className="text-xs text-buddy-text-secondary mb-3">Your profile will be hidden but recoverable for 30 days. Log in during this period to reactivate.</p>
          <Button variant="ghost" size="sm" className="text-buddy-orange" onClick={() => setDeactivateOpen(true)}>
            Deactivate Account
          </Button>
        </Card>

        <Card className="p-4 border-buddy-red/30 bg-buddy-red/5">
          <p className="text-sm font-medium text-buddy-red">Delete Account</p>
          <p className="text-xs text-buddy-text-secondary mb-3">
            Permanently delete your account and all associated data. Requires your current password. This cannot be undone.
          </p>
          <Input value={deleteConfirm} onChange={(e) => setDeleteConfirm(e.target.value)}
            placeholder={`Type "${DELETE_PHRASE}" to confirm`} className="mb-2" />
          <Input type="password" value={deletePassword} onChange={(e) => setDeletePassword(e.target.value)}
            placeholder="Current password" className="mb-2" />
          {deleteError && <p className="text-xs text-buddy-red mb-2">{deleteError}</p>}
          <Button variant="destructive" size="sm" onClick={handleDelete}
            disabled={deleteConfirm !== DELETE_PHRASE || !deletePassword} isLoading={isDeleting}>
            <Trash2 size={14} className="mr-1" /> Delete Account
          </Button>
        </Card>
      </div>

      <Modal isOpen={deactivateOpen} onClose={() => setDeactivateOpen(false)} title="Deactivate Account?" size="sm">
        <p className="text-sm text-buddy-text-secondary mb-4">
          Your profile will be hidden for 30 days. Logging in again during that time reactivates it — after 30 days the account is scheduled for deletion.
        </p>
        <div className="flex gap-2">
          <Button variant="ghost" size="sm" className="flex-1" onClick={() => setDeactivateOpen(false)}>Cancel</Button>
          <Button variant="destructive" size="sm" className="flex-1" onClick={handleDeactivate} isLoading={isDeactivating}>
            Deactivate
          </Button>
        </div>
      </Modal>
    </SectionShell>
  );
}
