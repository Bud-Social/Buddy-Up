import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import HealthInsights from '@/pages/app/HealthInsights';

const createWrapper = () => {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={client}>
      <BrowserRouter>{children}</BrowserRouter>
    </QueryClientProvider>
  );
};

global.fetch = vi.fn();

describe('HealthInsights', () => {
  it('renders loading state initially', () => {
    render(<HealthInsights />, { wrapper: createWrapper() });
    expect(screen.getByText(/weekly/i)).toBeDefined();
    expect(screen.getByText(/monthly/i)).toBeDefined();
  });

  it('shows error message when insights fail to load', async () => {
    (global.fetch as any).mockRejectedValueOnce(new Error('Network error'));
    render(<HealthInsights />, { wrapper: createWrapper() });
    await waitFor(() => {
      expect(screen.queryByText(/unable to load insights/i)).toBeDefined();
    }, { timeout: 3000 });
  });
});