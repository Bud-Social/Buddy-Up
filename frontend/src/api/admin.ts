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

export interface ScrapeBatch {
  task: string;
  batch: string;
  mb: number;
  n: number | null;
  source: string;
  mtime: number;
}

export interface LoaderStatus {
  disk: { total_gb: number; used_gb: number; free_gb: number };
  sources: Array<{ name: string; mb: number }>;
  batches: ScrapeBatch[];
  tasks: string[];
  degraded?: boolean;
}

export interface RegisterModelPayload {
  name: string;
  version: string;
  artifact_path?: string;
  framework?: string;
  description?: string;
  metrics?: Record<string, number>;
  activate?: boolean;
  deactivate?: boolean;
  deactivate_others?: boolean;
}

export interface ModelTestResult {
  model: string;
  route: string;
  active_version: string | null;
  artifact_path: string;
  elapsed_ms: number;
  status_code: number;
  result: unknown;
}

export const TEST_ROUTES: Array<{ route: string; model: string; kind: 'text' | 'image' | 'json'; sample: string }> = [
  { route: '/api/v1/moderation/text', model: 'toxicity_classifier', kind: 'text', sample: 'You are an idiot, nobody likes you.' },
  { route: '/api/v1/moderation/image', model: 'nsfw_classifier', kind: 'image', sample: '' },
  { route: '/api/v1/embeddings/text', model: 'matching_embeddings', kind: 'text', sample: 'morning strength training partner' },
  { route: '/api/v1/embeddings/image', model: 'matching_embeddings', kind: 'image', sample: '' },
  { route: '/api/v1/embeddings/clip-text', model: 'matching_embeddings', kind: 'text', sample: 'person doing yoga at sunrise' },
  { route: '/api/v1/food/recognize', model: 'food_calorie_regressor', kind: 'image', sample: '' },
  { route: '/api/v1/form-analyzer/analyze', model: 'form_analyzer', kind: 'image', sample: '' },
  { route: '/api/v1/feed/rank', model: 'feed_ranker', kind: 'json', sample: '{"user_id": "demo", "candidates": [{"id": "p1", "text": "morning run done"}, {"id": "p2", "text": "protein pancakes"}], "bandit": false}' },
  { route: '/api/v1/workout/analyze', model: 'workout_forecast', kind: 'json', sample: '{"history": [{"workout_type": "strength", "duration_minutes": 45, "calories": 320}]}' },
];

export const adminApi = {
  getDashboard: () =>
    apiClient.get<ApiResponse<DashboardData>>('/admin/dashboard/').then((r) => r.data),

  getScrapers: () =>
    apiClient.get<ApiResponse<ScrapeBatch[]>>('/admin/dashboard/scrapers/').then((r) => r.data),

  getLoaders: () =>
    apiClient.get<ApiResponse<LoaderStatus>>('/admin/dashboard/loaders/').then((r) => r.data),

  registerModel: (payload: RegisterModelPayload) =>
    apiClient.post<ApiResponse<ModelMetadataItem>>('/admin/dashboard/models/register/', payload).then((r) => r.data),

  testModel: (route: string, input: { text?: string; json?: string; image?: File }) => {
    const form = new FormData();
    form.append('route', route);
    if (input.text !== undefined) form.append('text', input.text);
    if (input.json !== undefined) form.append('json', input.json);
    if (input.image) form.append('image', input.image);
    return apiClient.post<ApiResponse<ModelTestResult>>('/admin/dashboard/models/test/', form, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 150000,
    }).then((r) => r.data);
  },
  logTraining: (payload: LogTrainingPayload) =>
    apiClient.post<ApiResponse<TrainingRun>>('/admin/dashboard/log-training/', payload).then((r) => r.data),
};
