import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card } from '@/components/ui/Card';
import { Shield, Smartphone, KeyRound } from 'lucide-react';
import { authApi } from '@/api';

export default function TotpSetup() {
  const navigate = useNavigate();
  const [step, setStep] = useState<'loading' | 'show_qr' | 'verify' | 'done'>('loading');
  const [qrCode, setQrCode] = useState('');
  const [secret, setSecret] = useState('');
  const [code, setCode] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    authApi.setupTotp()
      .then((res) => {
        setQrCode(res.data.qr_code);
        setSecret(res.data.secret);
        setStep('show_qr');
      })
      .catch(() => {
        setStep('done');
        navigate('/settings');
      });
  }, [navigate]);

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      await authApi.verifyTotp(secret, code);
      setStep('done');
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Verification failed. Try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (step === 'done') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
        <Card className="w-full max-w-md p-8 text-center bg-buddy-surface">
          <Shield size={48} className="text-buddy-green mx-auto mb-4" />
          <h1 className="font-display text-2xl font-extrabold mb-2 text-buddy-green">2FA Enabled</h1>
          <p className="text-buddy-text-secondary mb-6">Your account is now protected with two-factor authentication.</p>
          <Button onClick={() => navigate('/settings')} className="w-full">Back to Settings</Button>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4 bg-buddy-black">
      <Card className="w-full max-w-md p-8 bg-buddy-surface">
        <div className="flex items-center gap-3 mb-6">
          <Shield size={24} className="text-buddy-green" />
          <h1 className="font-display text-2xl font-extrabold">Setup 2FA</h1>
        </div>

        {step === 'loading' && (
          <div className="text-center py-8">
            <div className="animate-pulse space-y-4">
              <div className="w-48 h-48 bg-buddy-surface-raised rounded-xl mx-auto" />
              <div className="h-4 bg-buddy-surface-raised rounded w-3/4 mx-auto" />
            </div>
          </div>
        )}

        {step === 'show_qr' && (
          <>
            <p className="text-sm text-buddy-text-secondary mb-4">
              Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.):
            </p>
            <div className="flex justify-center mb-4">
              <img src={qrCode} alt="TOTP QR Code" className="w-48 h-48 rounded-xl bg-white p-2" />
            </div>
            <div className="bg-buddy-surface-raised rounded-xl p-3 mb-4">
              <p className="text-xs text-buddy-text-secondary mb-1">Or enter this key manually:</p>
              <p className="font-mono text-sm text-buddy-green break-all">{secret}</p>
            </div>
            <div className="flex items-center gap-2 mb-4">
              <KeyRound size={16} className="text-buddy-text-secondary" />
              <p className="text-xs text-buddy-text-secondary">
                Enter the 6-digit code from your authenticator app to confirm setup.
              </p>
            </div>
            <form onSubmit={handleVerify} className="space-y-4">
              <Input
                label="Authenticator Code"
                value={code}
                onChange={(e) => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="000000"
                maxLength={6}
                required
              />
              {error && <div className="bg-buddy-red/10 border border-buddy-red/30 text-buddy-red rounded-xl p-3 text-sm">{error}</div>}
              <Button type="submit" isLoading={isLoading} disabled={code.length !== 6} className="w-full">
                Verify & Enable 2FA
              </Button>
            </form>
          </>
        )}
      </Card>
    </div>
  );
}
