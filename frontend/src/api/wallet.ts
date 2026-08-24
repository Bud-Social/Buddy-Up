import { apiClient } from './client';
import type { ApiResponse, ArtifactTransaction } from '@/types';

export interface BalanceItem {
  artifact_type: string;
  label: string;
  quantity: number;
  usd_value: number;
}

export interface BalanceResponse {
  balance: BalanceItem[];
  total_label: string;
  total_fiat: number;
  fiat_currency: string;
  regular_balance: BalanceItem[];
  regular_total_fiat: number;
  creator_balance: BalanceItem[];
  creator_total_fiat: number;
  creator_display_name: string;
}

export interface BundleInfo {
  id: string;
  artifact_type: string;
  artifact_label: string;
  quantity: number;
  price_usd: number;
  savings: number;
}

export interface InitializeResponse {
  tx_ref: string;
  flutterwave_ref?: string;
  status?: string;
  requires_otp?: boolean;
  public_key: string;
  amount?: number;
  currency?: string;
  customer_email?: string;
  customer_name?: string;
}

export interface BankInfo {
  code: string;
  name: string;
}

export const walletApi = {
  getBalance: () =>
    apiClient.get<ApiResponse<BalanceResponse>>('/wallet/balance/').then((r) => r.data),

  getTransactions: (params?: { type?: string; direction?: string; cursor?: string }) =>
    apiClient.get<ApiResponse<ArtifactTransaction[]>>('/wallet/transactions/', { params }).then((r) => r.data),

  initializePurchase: (artifact_type: string, quantity: number, payment_method: string, options?: { bundle?: string; mpesa_phone?: string; card_details?: Record<string, string> }) =>
    apiClient.post<ApiResponse<InitializeResponse>>('/wallet/purchase/initialize/', {
      artifact_type, quantity, payment_method, ...options,
    }).then((r) => r.data),

  confirmPurchase: (tx_ref: string, flutterwave_id: string) =>
    apiClient.post<ApiResponse<{ transaction: ArtifactTransaction; new_balance: Record<string, number> }>>('/wallet/purchase/confirm/', {
      tx_ref, flutterwave_id,
    }).then((r) => r.data),

  tip: (username: string, artifact_type: string, quantity: number, message?: string) =>
    apiClient.post<ApiResponse<null>>('/wallet/tip/', { username, artifact_type, quantity, message }).then((r) => r.data),

  gift: (username: string, artifact_type: string, quantity: number, message?: string) =>
    apiClient.post<ApiResponse<null>>('/wallet/gift/', { username, artifact_type, quantity, message }).then((r) => r.data),

  withdraw: (artifact_type: string, quantity: number, method: string, options?: { phone_number?: string; bank_account?: string; bank_code?: string; account_name?: string; source?: 'regular' | 'creator' }) =>
    apiClient.post<ApiResponse<ArtifactTransaction>>('/wallet/withdraw/', {
      artifact_type, quantity, method, ...options,
    }).then((r) => r.data),

  getBanks: (country?: string) =>
    apiClient.get<ApiResponse<BankInfo[]>>('/wallet/withdraw/banks/', { params: country ? { country } : {} }).then((r) => r.data),

  resolveBank: (account_number: string, bank_code: string) =>
    apiClient.post<ApiResponse<{ account_number: string; bank_code: string; account_name: string }>>('/wallet/withdraw/bank-resolve/', {
      account_number, bank_code,
    }).then((r) => r.data),

  getBundles: () =>
    apiClient.get<ApiResponse<BundleInfo[]>>('/wallet/bundles/').then((r) => r.data),

  getExchangeRates: () =>
    apiClient.get<ApiResponse<{ rates: Record<string, number>; base_currency: string; local_currency: string; conversion_rate: number; labels: Record<string, string> }>>('/wallet/exchange-rates/').then((r) => r.data),

  transferFromCreator: (artifact_type: string, quantity: number) =>
    apiClient.post<ApiResponse<{ regular_balance: Record<string, number>; creator_balance: Record<string, number> }>>('/wallet/creator/transfer/', {
      artifact_type, quantity,
    }).then((r) => r.data),

  updateCreatorProfile: (data: { creator_display_name?: string }) =>
    apiClient.patch<ApiResponse<{ creator_display_name: string; creator_balance: Record<string, number> }>>('/wallet/creator/profile/', data).then((r) => r.data),

  requestPayout: (data: { amount?: number; artifact_type?: string; quantity?: number; method: string; phone_number?: string; bank_account?: string; bank_code?: string; account_name?: string }) =>
    apiClient.post<ApiResponse<ArtifactTransaction>>('/wallet/payout-request/', data).then((r) => r.data),

  getPayoutHistory: () =>
    apiClient.get<ApiResponse<ArtifactTransaction[]>>('/wallet/payout-history/').then((r) => r.data),
};

