import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import userEvent from '@testing-library/user-event';
import CreateGymPage from '@/pages/app/CreateGymPage';
import { gymsApi } from '@/api/gyms';

vi.mock('@/api/gyms', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@/api/gyms')>()),
  gymsApi: {
    getCategories: vi.fn(),
    checkHandle: vi.fn(),
    create: vi.fn(),
    createVenue: vi.fn(),
  },
}));

const api = gymsApi as unknown as Record<string, ReturnType<typeof vi.fn>>;
const envelope = (data: unknown) => ({ data, success: true });

function renderPage() {
  return render(
    <MemoryRouter initialEntries={['/gyms/create']}>
      <CreateGymPage />
    </MemoryRouter>,
  );
}

describe('Gym creation wizard', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    api.getCategories.mockResolvedValue(envelope([
      { id: 'c1', name: 'fitness', display_name: 'Fitness', icon: '', is_active: true },
    ]));
    api.checkHandle.mockResolvedValue(envelope({ available: true, suggested: null }));
    api.create.mockResolvedValue(envelope({ handle: 'test_gym' }));
    api.createVenue.mockResolvedValue(envelope({ id: 'v1' }));
  });

  it('always offers a custom category input instead of hiding it behind an "other" chip', async () => {
    renderPage();
    expect(
      await screen.findByPlaceholderText(/Add your own category/i),
    ).toBeInTheDocument();
  });

  it('collects locations before the review step and creates them after the gym', async () => {
    const user = userEvent.setup();
    renderPage();

    await user.type(screen.getByLabelText('Gym Name'), 'Test Gym');
    await user.click(await screen.findByRole('button', { name: 'Fitness' }));
    await user.click(screen.getByRole('button', { name: 'Next' }));

    // Step 2: access + subscription.
    await user.click(screen.getByRole('button', { name: 'Next' }));

    // Step 3: locations.
    expect(screen.getByText('Locations', { selector: 'h2' })).toBeInTheDocument();
    await user.type(screen.getByPlaceholderText('Location name'), 'Downtown');
    await user.click(screen.getByRole('button', { name: 'Next' }));

    // Step 4: review, then create.
    expect(screen.getByText('Review your gym')).toBeInTheDocument();
    expect(screen.getByText('Downtown')).toBeInTheDocument();
    await user.click(screen.getByRole('button', { name: 'Create Gym' }));

    await waitFor(() => expect(api.createVenue).toHaveBeenCalledWith(
      'test_gym',
      expect.objectContaining({ name: 'Downtown', is_primary: true }),
    ));
  });
});
