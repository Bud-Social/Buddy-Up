import { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { Loader2, Mail, CheckCircle, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { authApi } from '@/api';

export default function Activate() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [message, setMessage] = useState('');
  const [loginToken, setLoginToken] = useState('');
  const [maskedEmail, setMaskedEmail] = useState('');

  useEffect(() => {
    const token = searchParams.get('token');
    if (!token) {
      setStatus('error');
      setMessage('Invalid activation link. Please request a new one.');
      return;
    }

    const activate = async () => {
      try {
        const res = await authApi.activateAccount(token);
        const data = res.data;
        if (data.require_otp && data.login_token) {
          setStatus('success');
          setMessage(data.message || 'Email verified! Please log in to continue.');
          setLoginToken(data.login_token);
          setMaskedEmail(data.masked_email || '');
        } else {
          setStatus('error');
          setMessage(data.message || 'Activation failed. Please try again.');
        }
      } catch (err) {
        const msg = (err as any)?.response?.data?.message || 'Activation failed. Please try again.';
        setStatus('error');
        setMessage(msg);
      }
    };
    activate();
  }, [searchParams]);

  const handleGoToLogin = () => {
    if (loginToken && maskedEmail) {
      navigate(`/login?token=${encodeURIComponent(loginToken)}&email=${encodeURIComponent(maskedEmail)}`, { replace: true });
    } else {
      navigate('/login', { replace: true });
    }
  };

  return (
    <div className="min-h-screen bg-buddy-black flex items-center justify-center px-4 py-12">
      <Card className="w-full max-w-md">
        <div className="text-center mb-8">
          {status === 'loading' && (
            <>
              <Loader2 className="w-16 h-16 text-buddy-green animate-spin mx-auto mb-4" />
              <h1 className="font-display text-2xl font-extrabold text-buddy-text-primary mb-2">
                Activating your account
              </h1>
              <p className="text-buddy-text-secondary">Please wait...</p>
            </>
          )}
          {status === 'success' && (
            <>
              <CheckCircle className="w-16 h-16 text-buddy-green mx-auto mb-4" />
              <h1 className="font-display text-2xl font-extrabold text-buddy-text-primary mb-2">
                Email Verified!
              </h1>
              <p className="text-buddy-text-secondary mb-6">{message}</p>
              <Button onClick={handleGoToLogin} size="lg" className="w-full">
                Continue to Login
              </Button>
            </>
          )}
          {status === 'error' && (
            <>
              <AlertCircle className="w-16 h-16 text-buddy-red mx-auto mb-4" />
              <h1 className="font-display text-2xl font-extrabold text-buddy-red mb-2">
                Activation Failed
              </h1>
              <p className="text-buddy-text-secondary mb-6">{message}</p>
              <Button variant="outline" onClick={() => navigate('/login', { replace: true })} size="lg" className="w-full">
                Go to Login
              </Button>
            </>
          )}
        </div>

        <div className="text-center text-sm text-buddy-text-secondary">
          <p>Didn't create an account? <a href="/login" className="text-buddy-green hover:underline">Log in</a> or <a href="/signup" className="text-buddy-green hover:underline">Sign up</a></p>
        </div>
      </Card>
    </div>
  );
}
