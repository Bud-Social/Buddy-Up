import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { DataTab } from '@/components/admin/DataTab';
import { PerformanceTab } from '@/components/admin/PerformanceTab';
import { TestingTab } from '@/components/admin/TestingTab';
import { adminApi } from '@/api/admin';

vi.mock('@/api/admin', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/admin')>();
  return {
    ...actual,
    adminApi: {
      ...actual.adminApi,
      getScrapers: vi.fn(),
      getLoaders: vi.fn(),
      testModel: vi.fn(),
    },
  };
});

const mockGetScrapers = adminApi.getScrapers as unknown as ReturnType<typeof vi.fn>;
const mockGetLoaders = adminApi.getLoaders as unknown as ReturnType<typeof vi.fn>;
const mockTestModel = adminApi.testModel as unknown as ReturnType<typeof vi.fn>;

beforeEach(() => {
  vi.clearAllMocks();
});

describe('DataTab', () => {
  it('renders disk, sources, and scrape batches', async () => {
    mockGetScrapers.mockResolvedValue({
      success: true,
      data: [{ task: 'nlp_text', batch: 'b1', mb: 12.5, n: 1000, source: 'reddit', mtime: Date.now() / 1000 }],
    });
    mockGetLoaders.mockResolvedValue({
      success: true,
      data: {
        disk: { total_gb: 100, used_gb: 90, free_gb: 10 },
        sources: [{ name: 'nsfw', mb: 800 }],
        batches: [], tasks: ['nlp_text'],
      },
    });
    render(<DataTab />);
    await waitFor(() => {
      expect(screen.getByText(/Training disk/)).toBeDefined();
      expect(screen.getByText(/nlp_text\/b1/)).toBeDefined();
    });
  });

  it('shows the degraded badge when the agent is unreachable', async () => {
    mockGetScrapers.mockResolvedValue({ success: true, data: [] });
    mockGetLoaders.mockResolvedValue({
      success: true,
      data: { disk: { total_gb: 100, used_gb: 90, free_gb: 10 }, sources: [], batches: [], tasks: [], degraded: true },
    });
    render(<DataTab />);
    await waitFor(() => {
      expect(screen.getByText(/agent unreachable/)).toBeDefined();
    });
  });
});

describe('PerformanceTab', () => {
  const data = {
    models: [{ id: 1, name: 'nsfw_classifier', version: '2.0.0', is_active: true, artifact_path: 'm.onnx' }],
    runs: [
      { id: 1, model_name: 'nsfw_classifier', version: '1.0.0', status: 'completed', scenario: 'demo', framework: 'pytorch', metrics: { accuracy: 0.9 }, created_at: '2026-01-01T00:00:00Z' },
      { id: 2, model_name: 'nsfw_classifier', version: '2.0.0', status: 'completed', scenario: 'full', framework: 'pytorch', metrics: { accuracy: 0.97 }, created_at: '2026-02-01T00:00:00Z' },
      { id: 3, model_name: 'nsfw_classifier', version: '2.1.0', status: 'failed', scenario: 'full', framework: 'pytorch', metrics: {}, created_at: '2026-03-01T00:00:00Z' },
    ],
    health: {},
  } as never;

  it('picks the best completed run and the live version', () => {
    render(<PerformanceTab data={data} />);
    expect(screen.getByText(/live: 2\.0\.0/)).toBeDefined();
    expect(screen.getByText(/3 runs/)).toBeDefined();
    expect(screen.getByText(/1 failed/)).toBeDefined();
  });
});

describe('TestingTab', () => {
  it('runs a text probe and shows latency plus result', async () => {
    mockTestModel.mockResolvedValue({
      success: true,
      data: {
        model: 'toxicity_classifier', route: '/api/v1/moderation/text',
        active_version: '2.0.0', artifact_path: 'm.onnx',
        elapsed_ms: 210, status_code: 200, result: { label: 'clean' },
      },
    });
    render(<TestingTab onTested={() => undefined} />);
    fireEvent.click(screen.getByRole('button', { name: /Run test/ }));
    await waitFor(() => {
      expect(screen.getByText(/210 ms/)).toBeDefined();
    });
    expect(mockTestModel).toHaveBeenCalledWith(
      '/api/v1/moderation/text',
      expect.objectContaining({ text: expect.any(String) }),
    );
  });
});
