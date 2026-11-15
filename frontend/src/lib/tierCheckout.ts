/**
 * Post-gym-creation verification-tier checkout.
 *
 * Two call sites share it: the creation wizard (paid tier picked before the
 * gym exists) and the manage dashboard's Setup tab (upgrading later). Card
 * payments go through the Flutterwave inline widget; if the backend could
 * create a payment plan for the (tier, currency) pair it is attached and
 * Flutterwave charges monthly automatically. M-Pesa triggers an STK push.
 *
 * The gym always exists by now — creating the gym row first and paying
 * second means a closed/failed checkout never leaves the platform with a
 * phantom gym or a free tier.
 */
import { tierApi } from '@/api/gyms';

export interface TierCheckoutResult {
  status: 'confirmed' | 'closed' | 'failed';
  message?: string;
}

interface InitializePayload {
  tx_ref?: string;
  amount?: number;
  currency?: string;
  tier?: string;
  country?: string;
  public_key?: string;
  customer_email?: string;
  customer_name?: string;
  payment_plan?: string;
  flutterwave_ref?: string;
  status?: string;
}

export async function startTierCheckout(
  slug: string,
  tier: 'midlevel' | 'executive' | 'regular',
  phone?: string,
): Promise<TierCheckoutResult> {
  if (tier === 'regular') return { status: 'confirmed' };

  const method: 'card' | 'mpesa' = phone?.trim() ? 'mpesa' : 'card';
  const res = await tierApi.tierCheckout(slug, tier, method, phone?.trim() || undefined);
  const data = (res?.data ?? {}) as InitializePayload;
  if (!data.tx_ref) {
    return { status: 'failed', message: (res?.message as string | undefined) || 'Could not start checkout.' };
  }

  if (method === 'mpesa') {
    return { status: 'confirmed', message: 'M-Pesa prompt sent. Complete the payment on your phone.' };
  }

  if (typeof window.FlutterwaveCheckout !== 'function') {
    return { status: 'failed', message: 'Payment widget failed to load. Refresh and try again.' };
  }

  return new Promise<TierCheckoutResult>((resolve) => {
    window.FlutterwaveCheckout({
      public_key: data.public_key || '',
      tx_ref: data.tx_ref || '',
      amount: data.amount ?? 0,
      currency: data.currency || 'KES',
      payment_plan: data.payment_plan || undefined,
      payment_options: 'card',
      customer: {
        email: data.customer_email || '',
        name: data.customer_name || '',
      },
      callback: async (response) => {
        if (response?.status === 'successful' || response?.status === 'completed') {
          try {
            await tierApi.tierConfirm(slug, data.tx_ref || '', String(response?.transaction_id ?? ''));
            resolve({ status: 'confirmed' });
          } catch (err: unknown) {
            resolve({
              status: 'failed',
              message: (err as { response?: { data?: { message?: string } } })?.response?.data?.message
                || 'Payment verified but tier activation failed. Contact support with your payment reference.',
            });
          }
        } else {
          resolve({ status: 'failed', message: 'Payment was not completed.' });
        }
      },
      onclose: () => resolve({ status: 'closed' }),
      customizations: {
        title: 'BuddyUp Fit',
        description: `Upgrade ${slug} to the ${tier} verification tier`,
        logo: 'https://buddyup.app/logo.png',
      },
    });
  });
}
