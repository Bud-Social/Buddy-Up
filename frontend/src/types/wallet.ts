export type TransactionType = 'purchase' | 'tip_sent' | 'tip_received' | 'live_fee' | 'gym_subscription' | 'session_fee' | 'marketplace' | 'withdrawal' | 'platform_cut' | 'refund' | 'bonus';
export type TransactionStatus = 'pending' | 'completed' | 'failed' | 'refunded' | 'held';

export interface ArtifactTransaction {
  id: string;
  transaction_type: TransactionType;
  artifact_type: string;
  quantity: number;
  direction: 'credit' | 'debit';
  counterparty_id: string | null;
  counterparty_name: string | null;
  reference_id: string;
  status: TransactionStatus;
  fiat_amount: string | null;
  fiat_currency: string;
  description: string;
  clearance_at: string | null;
  created_at: string;
}

export interface ArtifactBalance {
  dumbbell: number;
  barbell: number;
  burpee: number;
  squat: number;
  sprint: number;
  pr: number;
  champion: number;
}
