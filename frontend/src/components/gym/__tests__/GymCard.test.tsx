import { describe, expect, it } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { GymCard } from '@/components/gym/GymCard';
import type { Gym } from '@/types';

const baseGym = {
  id: 'g1',
  name: 'Karura Fitness',
  handle: 'karura',
  description: '',
  logo_url: '',
  cover_url: '',
  category: 'fitness',
  categories: [],
  access_type: 'public',
  subscription_type: 'free',
  is_verified: false,
  is_reviews_enabled: false,
  is_donations_enabled: false,
  member_count: 120,
  rules: [],
  tags: [],
  location_city: '',
  location_country: '',
  owner_data: [],
  created_at: '',
  updated_at: '',
} as unknown as Gym;

function renderCard(gym: Gym) {
  return render(
    <MemoryRouter>
      <GymCard gym={gym} />
    </MemoryRouter>,
  );
}

describe('GymCard', () => {
  it('marks a verified gym with the dumbbell badge', () => {
    renderCard({ ...baseGym, is_verified: true });
    expect(screen.getByLabelText('Verified gym')).toBeInTheDocument();
  });

  it('does not mark an unverified gym', () => {
    renderCard(baseGym);
    expect(screen.queryByLabelText('Verified gym')).not.toBeInTheDocument();
  });

  it('names the followed members shown on the right and counts the rest', () => {
    renderCard({
      ...baseGym,
      followed_members: [
        { user_id: 'u1', username: 'ada', display_name: 'Ada Lovelace', avatar_url: '' },
      ],
      followed_members_count: 3,
    });
    expect(screen.getByText('Ada Lovelace +2 others')).toBeInTheDocument();
  });

  it('shows a multi-location gym as multiple locations with the nearest distance', () => {
    renderCard({
      ...baseGym,
      location_summary: {
        has_physical: true,
        venue_count: 2,
        cities: ['Westlands', 'Karen'],
        nearest_km: 2.4,
      },
    });
    expect(screen.getByText(/Westlands · Karen/)).toBeInTheDocument();
    expect(screen.getByText(/nearest 2\.4 km away/)).toBeInTheDocument();
  });

  it('falls back to the city for a single-location gym', () => {
    renderCard({
      ...baseGym,
      location_summary: { has_physical: true, venue_count: 1, cities: ['Nairobi'], nearest_km: null },
    });
    expect(screen.getByText('Nairobi')).toBeInTheDocument();
  });
});
