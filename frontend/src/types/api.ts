export interface GeoMeta {
  lat: number;
  lng: number;
  radius_km: number;
  auto: boolean;
  density: 'dense' | 'sparse' | null;
  count_in_near: number | null;
  message: string | null;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
  errors: Record<string, string[]> | null;
  pagination: Pagination | null;
  geo?: GeoMeta | null;
}

export interface Pagination {
  count: number;
  next: string | null;
  previous: string | null;
}
