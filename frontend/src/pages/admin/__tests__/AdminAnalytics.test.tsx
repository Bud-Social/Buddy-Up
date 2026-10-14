import { describe, expect, it, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor, within, act } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import AdminAnalytics from '@/pages/admin/AdminAnalytics';
import {
  adminPortalApi,
  exportAnalyticsReport,
  saveAnalyticsFile,
  type AnalyticsOverview,
  type AnalyticsPredictive,
  type AnalyticsAIQuality,
  type AnalyticsTimeseries,
  type AnalyticsTrending,
} from '@/api/adminPortal';

/**
 * Contract tests for the platform analytics console.
 *
 * Each one pins a claim the API makes in words, because every one of them is a
 * way the UI can quietly tell a staff member something false:
 *
 * - a gauge (`All time`) rendered as a period figure,
 * - a live-aggregated series presented as a rollup read,
 * - a zero-filled bucket dropped so the chart draws a line through it,
 * - `kind=pages` (which has no instrument at all) rendered as an empty result,
 * - a derived ratio listed beside counted signals,
 * - `accuracy_proxy` labelled "accuracy",
 * - a refused export presented as a downloaded file.
 */

vi.mock('@/api/adminPortal', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/adminPortal')>();
  return {
    ...actual,
    adminPortalApi: {
      getAnalyticsOverview: vi.fn(),
      getAnalyticsTimeseries: vi.fn(),
      getAnalyticsTrending: vi.fn(),
      getAnalyticsAIQuality: vi.fn(),
      getAnalyticsPredictive: vi.fn(),
    },
    exportAnalyticsReport: vi.fn(),
    saveAnalyticsFile: vi.fn(),
  };
});

const api = adminPortalApi;
const getOverview = api.getAnalyticsOverview as unknown as ReturnType<typeof vi.fn>;
const getTimeseries = api.getAnalyticsTimeseries as unknown as ReturnType<typeof vi.fn>;
const getTrending = api.getAnalyticsTrending as unknown as ReturnType<typeof vi.fn>;
const getAIQuality = api.getAnalyticsAIQuality as unknown as ReturnType<typeof vi.fn>;
const getPredictive = api.getAnalyticsPredictive as unknown as ReturnType<typeof vi.fn>;
const doExport = exportAnalyticsReport as unknown as ReturnType<typeof vi.fn>;
const saveFile = saveAnalyticsFile as unknown as ReturnType<typeof vi.fn>;

const envelope = (data: unknown) => ({ success: true, data, message: '', errors: null, pagination: null });

const WINDOW = {
  from: '2026-03-01',
  to: '2026-03-30',
  days: 30,
  basis: 'inclusive',
  timezone: 'UTC',
  label: '2026-03-01 to 2026-03-30 (UTC, inclusive)',
};

const OVERVIEW: AnalyticsOverview = {
  window: WINDOW,
  generated_at: '2026-03-30T12:00:00Z',
  groups: ['identity', 'content'],
  kpis: [
    {
      key: 'users.total', label: 'Total users', group: 'identity', unit: 'count',
      value: 41203, kind: 'gauge',
      window: { ...WINDOW, label: 'All time' },
      source: 'accounts.User', indexed: true, note: '',
    },
    {
      key: 'users.new', label: 'New users', group: 'identity', unit: 'count',
      value: 2914, kind: 'flow',
      window: { ...WINDOW, label: 'Window' },
      source: 'accounts.User.created_at', indexed: false,
      note: 'Accounts created inside the window.',
    },
    {
      key: 'posts.total', label: 'Total posts', group: 'content', unit: 'count',
      value: 88211, kind: 'gauge',
      window: { ...WINDOW, label: 'All time' },
      source: 'feed.Post', indexed: true, note: '',
    },
    {
      key: 'posts.new', label: 'New posts', group: 'content', unit: 'count',
      value: 4210, kind: 'flow',
      window: { ...WINDOW, label: 'Window' },
      source: 'feed.Post.created_at', indexed: false, note: '',
    },
  ],
  breakdowns: [],
  performance_notes: [
    {
      source: 'accounts.User.created_at',
      issue: 'no index; this figure costs a sequential scan until one exists',
      suggested_migration: 'AddIndex(fields=["-created_at"], name="accounts_user_created_idx")',
      owner: 'accounts',
    },
  ],
  table: { columns: ['key'], rows: [['users.total']] },
};

const LIVE_SERIES: AnalyticsTimeseries = {
  window: WINDOW,
  metric: { key: 'users.new', label: 'New users', unit: 'count', group: 'identity', source: 'accounts.User.created_at' },
  granularity: 'day',
  series: [
    { bucket: '2026-03-01', value: 4 },
    { bucket: '2026-03-02', value: 0 },
    { bucket: '2026-03-03', value: 7 },
  ],
  totals: { sum: 11, non_zero_buckets: 2 },
  data_source: {
    path: 'live',
    rollup_complete: false,
    missing_days: ['2026-03-02'],
    note: 'Served by aggregating the source table because the rollup has gaps in this window.',
  },
  available_metrics: ['users.new', 'posts.new'],
  metric_catalogue: [
    { key: 'users.new', label: 'New users', group: 'identity', unit: 'count', additive: true, windowed: true },
    { key: 'posts.new', label: 'New posts', group: 'content', unit: 'count', additive: true, windowed: true },
    { key: 'analytics.active_users', label: 'Active users', group: 'engagement', unit: 'count', additive: false, windowed: true },
  ],
  table: { columns: ['bucket'], rows: [] },
};

const ROLLUP_SERIES: AnalyticsTimeseries = {
  ...LIVE_SERIES,
  granularity: 'week',
  data_source: { path: 'rollup', rollup_complete: true, missing_days: [], note: 'Served from analytics_daily_platform_metric.' },
};

const HASHTAGS: AnalyticsTrending = {
  kind: 'hashtags',
  available: true,
  rank_basis: 'PostTag rows created inside the window, compared with the previous window.',
  window: WINDOW,
  items: [
    {
      rank: 1, tag: 'hyrox', tag_id: 'tag-1',
      posts_in_window: 120, posts_in_previous_window: 90,
      delta: 30, pct_change: 33.3, total_posts_ever: 845,
    },
    {
      rank: 2, tag: 'newcomers', tag_id: 'tag-2',
      posts_in_window: 40, posts_in_previous_window: 0,
      delta: 40, pct_change: null, total_posts_ever: 40,
    },
  ],
  table: { columns: ['tag'], rows: [] },
};

const PAGES_UNAVAILABLE: AnalyticsTrending = {
  kind: 'pages',
  available: false,
  reason: 'No client emits a route-change or screen-view event. There is no page_view event name in the analytics event stream.',
  window: WINDOW,
  items: [],
  table: { columns: ['note'], rows: [] },
};

const PREDICTIVE: AnalyticsPredictive = {
  window: WINDOW,
  disclaimer: 'This endpoint reports observed signals only. It does not forecast: there is no model here and no projection of any value.',
  signals: [
    {
      key: 'recommendation_feedback.total', label: 'Recommendation feedback rows',
      observed: true, derivation: 'directly counted',
      basis: 'RecommendationFeedback rows created in the window', value: 512,
    },
    {
      key: 'recommendation_feedback.negative_share', label: 'Negative feedback share',
      observed: false, derivation: 'derived from observed counts',
      basis: 'ratio: (not_interested + irrelevant) over all feedback rows in the window',
      value: 0.1875,
      note: 'Not a model score and not a forecast of churn.',
    },
  ],
  observed: {},
  table: { columns: ['section'], rows: [] },
};

const AI_QUALITY: AnalyticsAIQuality = {
  window: WINDOW,
  totals: {
    calls: 820, fallbacks: 41, fallback_rate: 0.05, corrections: 74,
    accuracy_proxy: 0.1237, cost_usd: 12.5, cost_per_call_usd: 0.0152,
    cumulative_cost_usd: 402.1, cumulative_calls: 24110, cumulative_cost_per_call_usd: 0.0167,
  },
  latency_ms: { samples: 820, sampled: false, sample_limit: 20000, p50: 340, p95: 2100, min: 90, max: 8400 },
  confidence_distribution: { window: WINDOW, with_confidence: 800, buckets: [{ bucket: '0.8-1.0', low: 0.8, high: 1.0001, count: 640 }] },
  fallback_reasons: [{ reason: 'model timeout', count: 41 }],
  models: [
    {
      model: 'coach-v4', task: 'workout_recommendation', model_version: '4.1',
      calls: 700, completed: 690, failed: 10, success_rate: 0.9857,
      fallbacks: 30, fallback_rate: 0.0429, corrections: 60,
      accuracy_proxy: 0.087, mean_confidence: 0.82, cost_usd: 10.5, cost_per_call_usd: 0.015,
    },
  ],
  caveats: [
    'AIPredictionJob has no ground-truth column. `correction` is written when a human overrides an AI output, so corrected/calls is a correction rate — a proxy for accuracy that is biased toward what people bother to correct. It is not a measured accuracy and is labelled accuracy_proxy everywhere it appears.',
  ],
  table: { columns: ['model'], rows: [] },
};

const ROW_CAP_MESSAGE =
  'The timeseries export would contain 61,204 rows, above the 50,000 row cap. Narrow the date range (a shorter window produces fewer buckets) and try again. The cap is ANALYTICS_EXPORT_MAX_ROWS. The file is not truncated silently because a truncated export would differ from the report you were looking at.';

const XLSX_MESSAGE =
  'xlsx export is unavailable on this deployment: the "openpyxl" package is not installed. It is declared in requirements/base.txt; rebuild the image or reinstall requirements. CSV export of the same report is unaffected.';

const renderPage = () => render(<MemoryRouter><AdminAnalytics /></MemoryRouter>);

const openTab = async (label: string | RegExp) => {
  await act(async () => {
    fireEvent.click(screen.getByRole('tab', { name: label }));
  });
};

beforeEach(() => {
  vi.clearAllMocks();
  getOverview.mockResolvedValue(envelope(OVERVIEW));
  getTimeseries.mockImplementation((params: { granularity: string }) =>
    Promise.resolve(envelope(params.granularity === 'week' ? ROLLUP_SERIES : LIVE_SERIES)),
  );
  getTrending.mockImplementation((params: { kind: string }) =>
    Promise.resolve(envelope(params.kind === 'pages' ? PAGES_UNAVAILABLE : HASHTAGS)),
  );
  getAIQuality.mockResolvedValue(envelope(AI_QUALITY));
  getPredictive.mockResolvedValue(envelope(PREDICTIVE));
  doExport.mockResolvedValue({ ok: false, status: 400, reason: 'row_cap', message: ROW_CAP_MESSAGE });
});

describe('AdminAnalytics — Overview', () => {
  it("renders each KPI with its OWN window label and separates gauge from flow", async () => {
    renderPage();

    await screen.findByTestId('kpi-window-users.total');

    // The gauge is cumulative: "All time", with only the cut-off date shown —
    // printing the window's `from` under "All time" would imply a period.
    expect(screen.getByTestId('kpi-window-users.total')).toHaveTextContent('All time — counted up to 2026-03-30');

    // The flow is a delta over the window, and says so.
    expect(screen.getByTestId('kpi-window-users.new')).toHaveTextContent('Window');
    expect(screen.getByTestId('kpi-window-users.new')).toHaveTextContent('2026-03-01 → 2026-03-30');
    expect(screen.getByTestId('kpi-window-users.new')).toHaveTextContent('30 days');

    // Gauge and flow are visibly different kinds of number, not two rows of the
    // same kind of list.
    expect(screen.getAllByText('Gauge')).toHaveLength(2);
    expect(screen.getAllByText('Flow')).toHaveLength(2);
  });

  it('discloses the missing created_at indexes in a dismissible panel', async () => {
    renderPage();
    await screen.findByTestId('kpi-window-users.total');

    expect(screen.getByText(/Performance notes/)).toBeInTheDocument();
    expect(screen.getAllByText(/accounts\.User\.created_at/).length).toBeGreaterThan(0);
    expect(screen.getByText(/AddIndex\(fields=\["-created_at"\]/)).toBeInTheDocument();

    fireEvent.click(screen.getByRole('button', { name: /Dismiss performance notes/i }));
    expect(screen.queryByText(/Performance notes/)).not.toBeInTheDocument();
  });
});

describe('AdminAnalytics — Trends', () => {
  it('plots the zero-filled series and says the numbers were computed live', async () => {
    renderPage();
    await openTab('Trends');
    await screen.findByText('2026-03-01');

    // The zero bucket is listed as a counted zero, not dropped.
    const zeroRow = screen.getByRole('cell', { name: '2026-03-02' }).closest('tr') as HTMLElement;
    expect(zeroRow).not.toBeNull();
    expect(within(zeroRow).getByText('0')).toBeInTheDocument();

    // 2 non-zero of 3 buckets — the totals agree with the plotted series.
    expect(screen.getByText('2 / 3')).toBeInTheDocument();

    // Live aggregation is called out, with the rollup's missing days named.
    expect(screen.getByText('Computed live')).toBeInTheDocument();
    expect(
      screen.getByText((_content, node) =>
        node?.tagName === 'P' && /Rollup missing 1 day:\s*2026-03-02/.test(node.textContent || ''),
      ),
    ).toBeInTheDocument();
  });

  it('says so when the same metric is served from the rollup instead', async () => {
    renderPage();
    await openTab('Trends');
    await screen.findByText('2026-03-01');

    fireEvent.click(screen.getByRole('button', { name: 'week' }));

    await waitFor(() => expect(screen.getByText('Served from the daily rollup')).toBeInTheDocument());
    expect(screen.queryByText('Computed live')).not.toBeInTheDocument();
  });

  it('builds the metric picker from the server catalogue, excluding non-additive metrics', async () => {
    renderPage();
    await openTab('Trends');
    await screen.findByText('2026-03-01');

    const picker = screen.getByLabelText('Metric') as HTMLSelectElement;
    const values = Array.from(picker.options).map((option) => option.value);
    expect(values).toEqual(['users.new', 'posts.new']);
    expect(values).not.toContain('analytics.active_users');
  });
});

describe('AdminAnalytics — Trending', () => {
  it('renders hashtag fields, including a null percent change', async () => {
    renderPage();
    await openTab('Trending');
    fireEvent.click(screen.getByRole('button', { name: 'Hashtags' }));

    await screen.findByText('hyrox');
    const row = screen.getByText('hyrox').closest('tr') as HTMLElement;

    expect(within(row).getByText('120')).toBeInTheDocument();   // posts_in_window
    expect(within(row).getByText('90')).toBeInTheDocument();    // posts_in_previous_window
    expect(within(row).getByText('+30')).toBeInTheDocument();  // delta
    expect(within(row).getByText('33.3%')).toBeInTheDocument();
    expect(within(row).getByText('845')).toBeInTheDocument();  // total_posts_ever

    // A tag that was absent in the previous window has no percentage, and the
    // cell says so rather than showing 0% or Infinity.
    const newcomerRow = screen.getByText('newcomers').closest('tr') as HTMLElement;
    expect(within(newcomerRow).getAllByText('—').length).toBeGreaterThan(0);
  });

  it('renders the server\'s reason as a "not available yet" panel for pages, never an empty chart', async () => {
    renderPage();
    await openTab('Trending');
    fireEvent.click(screen.getByRole('button', { name: 'Pages' }));

    const panel = await screen.findByTestId('trending-unavailable');
    expect(within(panel).getByText('Not available yet')).toBeInTheDocument();
    expect(within(panel).getByText(/No client emits a route-change/)).toBeInTheDocument();
    expect(screen.queryByText('Nothing matched in this window.')).not.toBeInTheDocument();
  });
});

describe('AdminAnalytics — AI quality', () => {
  it('never labels accuracy_proxy as accuracy', async () => {
    renderPage();
    await openTab('AI quality');
    await screen.findAllByText('Correction-rate proxy');

    // The figure is on screen...
    expect(screen.getAllByText('12.4%').length).toBeGreaterThan(0);
    expect(screen.getAllByText('8.7%').length).toBeGreaterThan(0);

    // ...and the only place the word "accuracy" appears is inside the server's
    // own caveat, which exists to say this is not accuracy. Anywhere else it is
    // a mislabel.
    const caveat = screen.getByTestId('ai-quality-caveats');
    const offenders = screen.getAllByText(/accuracy/i).filter((node) => !caveat.contains(node));
    expect(offenders).toHaveLength(0);
  });
});

describe('AdminAnalytics — Predictive', () => {
  it('separates observed signals from derived ones and shows the disclaimer', async () => {
    renderPage();
    await openTab('Predictive');

    const disclaimer = await screen.findByTestId('predictive-disclaimer');
    expect(disclaimer).toHaveTextContent('It does not forecast');

    const observed = screen.getAllByTestId('signal-observed');
    expect(observed).toHaveLength(1);
    expect(observed[0]).toHaveTextContent('Recommendation feedback rows');
    expect(observed[0]).toHaveTextContent('Observed');
    expect(observed[0]).toHaveTextContent('512');

    const derived = screen.getAllByTestId('signal-derived');
    expect(derived).toHaveLength(1);
    expect(derived[0]).toHaveTextContent('Negative feedback share');
    expect(derived[0]).toHaveTextContent('Derived');
    // A ratio, rendered as a percentage, and not sitting in the observed list.
    expect(derived[0]).toHaveTextContent('18.8%');
    expect(derived[0]).toHaveTextContent('not a forecast of churn');
  });
});

describe('AdminAnalytics — Export', () => {
  it('shows the row-cap refusal verbatim and never presents a file as complete', async () => {
    renderPage();
    await openTab('Export');

    fireEvent.click(screen.getByRole('button', { name: /Download CSV/i }));

    const refusal = await screen.findByTestId('export-row-cap');
    expect(refusal).toHaveTextContent(ROW_CAP_MESSAGE);
    expect(refusal).toHaveTextContent(/nothing on your disk is missing rows/i);
    expect(saveFile).not.toHaveBeenCalled();
  });

  it('names the missing xlsx dependency and offers the CSV that does work', async () => {
    doExport.mockResolvedValue({ ok: false, status: 503, reason: 'xlsx_unavailable', message: XLSX_MESSAGE });
    renderPage();
    await openTab('Export');

    fireEvent.click(screen.getByRole('button', { name: 'xlsx' }));
    fireEvent.click(screen.getByRole('button', { name: /Download XLSX/i }));

    const panel = await screen.findByTestId('export-error');
    expect(panel).toHaveTextContent(XLSX_MESSAGE);
    expect(panel).toHaveTextContent(/missing server dependency/i);

    // The offered fallback actually downloads, rather than only explaining.
    doExport.mockResolvedValue({
      ok: true,
      file: {
        blob: new Blob(['a,b\n1,2'], { type: 'text/csv' }),
        filename: 'analytics-overview_2026-03-01_2026-03-30.csv',
        report: 'overview',
        rows: 1,
        from: '2026-03-01',
        to: '2026-03-30',
      },
    });
    fireEvent.click(screen.getByRole('button', { name: /Download the same report as CSV/i }));

    await waitFor(() => expect(saveFile).toHaveBeenCalledTimes(1));
    const success = await screen.findByTestId('export-success');
    expect(success).toHaveTextContent('analytics-overview_2026-03-01_2026-03-30.csv');
    expect(success).toHaveTextContent('1 row');
  });

  it('passes the report, format and scoped params through to the endpoint', async () => {
    doExport.mockResolvedValue({
      ok: true,
      file: { blob: new Blob(['x']), filename: 'analytics-trending.csv', rows: 3 },
    });
    renderPage();
    await openTab('Export');

    fireEvent.change(screen.getByLabelText('Report'), { target: { value: 'trending' } });
    fireEvent.change(screen.getByLabelText('Kind'), { target: { value: 'hashtags' } });
    fireEvent.click(screen.getByRole('button', { name: /Download CSV/i }));

    await waitFor(() => expect(doExport).toHaveBeenCalled());
    expect(doExport.mock.calls[0][0]).toMatchObject({
      report: 'trending',
      format: 'csv',
      kind: 'hashtags',
      limit: 10,
    });
  });
});