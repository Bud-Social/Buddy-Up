export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
  errors: Record<string, string[]> | null;
  pagination: Pagination | null;
}

export interface Pagination {
  count: number;
  next: string | null;
  previous: string | null;
}
