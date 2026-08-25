import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import Onboarding from '@/pages/auth/Onboarding';

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

describe('Onboarding', () => {
  it('starts on the terms & consents step', () => {
    render(<Onboarding />, { wrapper: createWrapper() });
    expect(screen.getByText(/Before you start/i)).toBeDefined();
    expect(screen.getByText(/I accept the Terms of Service/i)).toBeDefined();
    expect(screen.getByText(/Privacy Policy/i)).toBeDefined();
    expect(screen.getByText(/Community Guidelines/i)).toBeDefined();
  });

  it('terms step requires all three acceptances before continuing', () => {
    render(<Onboarding />, { wrapper: createWrapper() });
    const next = screen.getByRole('button', { name: /next/i }) as HTMLButtonElement;
    expect(next.disabled).toBe(true);
  });
});
