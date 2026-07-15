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
  it('renders step 1 with goal options', () => {
    render(<Onboarding />, { wrapper: createWrapper() });
    expect(screen.getByText(/What are your primary fitness goals/i)).toBeDefined();
    expect(screen.getByText(/Weight Loss/i)).toBeDefined();
    expect(screen.getByText(/Muscle Gain/i)).toBeDefined();
  });
});