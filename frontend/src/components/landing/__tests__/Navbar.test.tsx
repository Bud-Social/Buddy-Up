import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Navbar } from '@/components/landing/Navbar';

describe('Navbar', () => {
  it('renders brand links and services menu', () => {
    render(
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>,
    );
    expect(screen.getByLabelText('Primary')).toBeDefined();
    expect(screen.getByText('About Us')).toBeDefined();
    expect(screen.getByText('Careers')).toBeDefined();
    expect(screen.getByText('Contact Us')).toBeDefined();
    fireEvent.click(screen.getByText('Services'));
    expect(screen.getByText('Live Workouts')).toBeDefined();
    expect(screen.getByText('Activity Analytics')).toBeDefined();
  });

  it('opens the mobile menu', () => {
    render(
      <MemoryRouter>
        <Navbar />
      </MemoryRouter>,
    );
    fireEvent.click(screen.getByLabelText('Open menu'));
    expect(screen.getByLabelText('Close menu')).toBeDefined();
  });
});

const mockSubmitCareer = vi.fn();

vi.mock('@/api/contact', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/api/contact')>();
  return {
    ...actual,
    submitCareer: (...args: unknown[]) => mockSubmitCareer(...args),
  };
});

import CareersPage from '@/pages/Careers';

describe('Careers page', () => {
  beforeEach(() => {
    mockSubmitCareer.mockReset();
  });

  it('lists roles and submits an application', async () => {
    mockSubmitCareer.mockResolvedValue({
      success: true, data: null, message: 'ok', errors: null, pagination: null,
    });
    render(
      <MemoryRouter>
        <CareersPage />
      </MemoryRouter>,
    );
    expect(screen.getAllByText('Founding Mobile Engineer').length).toBeGreaterThan(0);
    expect(screen.getAllByText('Community & Gym Partnerships Lead').length).toBeGreaterThan(0);
    fireEvent.change(screen.getByPlaceholderText('Wanjiku Mwangi'), {
      target: { value: 'Wanjiku' },
    });
    fireEvent.change(screen.getByPlaceholderText('you@example.com'), {
      target: { value: 'w@example.com' },
    });
    fireEvent.change(
      screen.getByPlaceholderText('Your experience, your fitness story, why BuddyUp Fit…'),
      { target: { value: 'I build apps.' } },
    );
    fireEvent.click(screen.getByRole('button', { name: 'Submit application' }));
    await waitFor(() => {
      expect(screen.getByText('Application received')).toBeDefined();
    });
    expect(mockSubmitCareer).toHaveBeenCalledWith(
      expect.objectContaining({ role: 'Founding Mobile Engineer' }),
    );
  });
});
