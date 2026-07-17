import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import WorkoutForm from '@/pages/app/WorkoutForm';

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

describe('WorkoutForm', () => {
  it('renders exercise selector buttons', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    expect(screen.getByText(/Auto Detect/i)).toBeDefined();
    expect(screen.getByText(/Squat/i)).toBeDefined();
    expect(screen.getByText(/Deadlift/i)).toBeDefined();
  });

  it('shows camera and upload buttons', () => {
    render(<WorkoutForm />, { wrapper: createWrapper() });
    expect(screen.getByRole('button', { name: /Camera/i })).toBeDefined();
    expect(screen.getByRole('button', { name: /Upload/i })).toBeDefined();
  });
});