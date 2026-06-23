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
}

export interface BundleInfo {
  id: string;
  artifact_type: string;
  artifact_label: string;
  quantity: number;
  price_usd: number;
  savings: number;
}

export const walletApi = {
  getBalance: () =>
    apiClient.get<ApiResponse<BalanceResponse>>('/wallet/balance/').then((r) => r.data),

  getTransactions: (params?: { type?: string; direction?: string; cursor?: string }) =>
    apiClient.get<ApiResponse<ArtifactTransaction[]>>('/wallet/transactions/', { params }).then((r) => r.data),

  purchase: (artifact_type: string, quantity: number, payment_method: string, bundle?: string) =>
    apiClient.post<ApiResponse<{ transaction: ArtifactTransaction; new_balance: Record<string, number> }>>('/wallet/purchase/', {
      artifact_type, quantity, payment_method, bundle,
    }).then((r) => r.data),

  tip: (username: string, artifact_type: string, quantity: number, message?: string) =>
    apiClient.post<ApiResponse<null>>('/wallet/tip/', { username, artifact_type, quantity, message }).then((r) => r.data),

  gift: (username: string, artifact_type: string, quantity: number, message?: string) =>
    apiClient.post<ApiResponse<null>>('/wallet/gift/', { username, artifact_type, quantity, message }).then((r) => r.data),

  withdraw: (artifact_type: string, quantity: number, method: string, phone_number?: string) =>
    apiClient.post<ApiResponse<ArtifactTransaction>>('/wallet/withdraw/', {
      artifact_type, quantity, method, phone_number,
    }).then((r) => r.data),

  getBundles: () =>
    apiClient.get<ApiResponse<BundleInfo[]>>('/wallet/bundles/').then((r) => r.data),

  getExchangeRates: () =>
    apiClient.get<ApiResponse<{ rates: Record<string, number>; base_currency: string; local_currency: string; conversion_rate: number; labels: Record<string, string> }>>('/wallet/exchange-rates/').then((r) => r.data),
};
