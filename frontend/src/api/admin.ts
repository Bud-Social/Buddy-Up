import { apiClient } from './client';
import type { ApiResponse } from '@/types';

export interface TrainingRun {
  id: number;
  model_name: string;
  version: string;
  scenario: string;
  framework: string;
  artifact_path: string;
  metrics: Record<string, number>;
  n_classes: number | null;
  status: 'running' | 'completed' | 'failed';
  source: 'notebook' | 'cli' | 'ci';
  duration_seconds: number | null;
  gpu: string;
  error: string;
  created_at: string;
}

export interface ModelMetadataItem {
  id: number;
  name: string;
  version: string;
  description: string;
  framework: string;
  input_schema: Record<string, unknown>;
  output_schema: Record<string, unknown>;
  metrics: Record<string, number>;
  artifact_path: string;
  is_active: boolean;
  created_at: string;
}

export interface DashboardHealth {
  models: { total: number; active: number };
  runs: { total: number; completed: number; failed: number; running: number; last_24h: number };
  last_training: string | null;
  last_training_by_model: Array<{ model_name: string; created_at: string }>;
  disk: { path: string; total_bytes: number; used_bytes: number; free_bytes: number; percent: number };
  artifact_dir: { path: string; exists: boolean };
  ai_service_url: string;
  mlflow_tracking_uri: string;
}

export interface DashboardData {
  models: ModelMetadataItem[];
  runs: TrainingRun[];
  health: DashboardHealth;
}

export interface LogTrainingPayload {
  model_name: string;
  version?: string;
  scenario?: string;
  framework?: string;
  artifact_path?: string;
  metrics?: Record<string, number>;
  n_classes?: number | null;
  status?: 'running' | 'completed' | 'failed';
  source?: 'notebook' | 'cli' | 'ci';
  duration_seconds?: number | null;
  gpu?: string;
  error?: string;
}

export const adminApi = {
  getDashboard: () =>
    apiClient.get<ApiResponse<DashboardData>>('/admin/dashboard/').then((r) => r.data),

  logTraining: (payload: LogTrainingPayload) =>
    apiClient.post<ApiResponse<TrainingRun>>('/admin/dashboard/log-training/', payload).then((r) => r.data),
};
