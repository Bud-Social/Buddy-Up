import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import ModerationQueue from '@/pages/app/ModerationQueue';
import { moderationApi } from '@/api/moderation';
import type { ContentFlag } from '@/api/moderation';

vi.mock('@/api/moderation', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/moderation')>()),
  moderationApi: {
    getQueue: vi.fn(),
    getStats: vi.fn(),
    actOnFlag: vi.fn(),
    listFlags: vi.fn(),
  },
}));

const api = moderationApi as unknown as Record<string, ReturnType<typeof vi.fn>>;

const envelope = (data: unknown) => ({ data, success: true });

/**
 * `waitFor` defaults to a 1s timeout, which is fine on a workstation and flaky
 * on a loaded CI runner rendering the whole suite in parallel. Every assertion
 * here waits on a promise chain (mock resolves -> state update -> re-render),
 * so the budget is explicit rather than inherited.
 */
const WAIT = { timeout: 5000 };

const waitUntil = (fn: () => void) => waitFor(fn, WAIT);

function flag(overrides: Partial<ContentFlag> = {}): ContentFlag {
  return {
    id: 'f1',
    flag_reason: 'toxic',
    severity: 'high',
    confidence: 0.82,
    source: 'ai_service',
    content_type: 'feed.post',
    content_id: '0066b560-26c1-4a45-9b15-4f40747077cd',
    content_preview: 'a post that was flagged',
    is_actioned: false,
    action_taken: '',
    created_at: '2026-03-01T00:00:00Z',
    ...overrides,
  } as ContentFlag;
}

function renderQueue() {
  return render(
    <MemoryRouter>
      <ModerationQueue />
    </MemoryRouter>,
  );
}

describe('moderation queue — model explanations', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    api.getQueue.mockResolvedValue(envelope([flag()]));
    api.getStats.mockResolvedValue(
      envelope({
        total: 1,
        unactioned: 1,
        by_reason: { toxic: 1 },
        by_severity: { critical: 0, high: 1, medium: 0, low: 0 },
      }),
    );
  });

  it('shows why the model flagged the content', async () => {
    api.getQueue.mockResolvedValue(
      envelope([
        flag({
          ai_explanation:
            'The safety classifier flagged this as unsafe or abusive (LABEL_1, 78% confidence).',
          ai_method: 'onnx_2.0.0',
          bias_assessed: false,
        }),
      ]),
    );
    renderQueue();

    await waitUntil(() => expect(screen.getByText('Why this was flagged')).toBeInTheDocument());
    expect(
      screen.getByText(/flagged this as unsafe or abusive \(LABEL_1, 78% confidence\)/),
    ).toBeInTheDocument();
  });

  it('names the layer that decided, so a rule is not read as a judgement', async () => {
    api.getQueue.mockResolvedValue(
      envelope([flag({ ai_explanation: 'A rule matched.', ai_method: 'keyword_rules' })]),
    );
    renderQueue();

    await waitUntil(() => expect(screen.getByText('Why this was flagged')).toBeInTheDocument());
    // The layer is named next to the heading, so a reviewer can tell a model's
    // judgement from a fixed rule's match.
    expect(screen.getByText(/keyword_rules/)).toBeInTheDocument();
  });

  it('says bias was NOT assessed, rather than letting silence imply none was found', async () => {
    api.getQueue.mockResolvedValue(
      envelope([flag({ ai_explanation: 'Flagged.', bias_assessed: false })]),
    );
    renderQueue();

    await waitUntil(() => expect(screen.getByText(/Bias was not assessed/i)).toBeInTheDocument());
  });

  it('omits the bias caveat once a bias model has actually run', async () => {
    api.getQueue.mockResolvedValue(
      envelope([flag({ ai_explanation: 'Flagged.', bias_assessed: true })]),
    );
    renderQueue();

    await waitUntil(() => expect(screen.getByText('Why this was flagged')).toBeInTheDocument());
    expect(screen.queryByText(/Bias was not assessed/i)).not.toBeInTheDocument();
  });

  it('renders a flag with no stored explanation without inventing one', async () => {
    // Hand-raised flags, and rows predating the field, have none. The UI must
    // not imply every flag came with a rationale.
    api.getQueue.mockResolvedValue(envelope([flag({ ai_explanation: undefined })]));
    renderQueue();

    await waitUntil(() =>
      expect(screen.getByText(/No model explanation was recorded/i)).toBeInTheDocument(),
    );
  });
});