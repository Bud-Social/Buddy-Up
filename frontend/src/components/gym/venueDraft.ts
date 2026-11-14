export interface VenueDraft {
  key: string;
  name: string;
  address: string;
  city: string;
  country: string;
  latitude: number | null;
  longitude: number | null;
  instructions: string;
  is_primary: boolean;
}

export function emptyVenueDraft(isPrimary = false): VenueDraft {
  return {
    key: `venue_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
    name: '',
    address: '',
    city: '',
    country: '',
    latitude: null,
    longitude: null,
    instructions: '',
    is_primary: isPrimary,
  };
}
