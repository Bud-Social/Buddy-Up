interface GoogleAccountsOAuth2TokenClientConfig {
  client_id: string;
  scope: string;
  callback: (response: GoogleAccountsOAuth2TokenResponse) => void;
  error_callback?: () => void;
}

interface GoogleAccountsOAuth2TokenResponse {
  access_token: string;
  id_token?: string;
  expires_in: number;
  token_type: string;
  scope: string;
}

interface GoogleAccountsOAuth2 {
  initTokenClient(config: GoogleAccountsOAuth2TokenClientConfig): {
    requestAccessToken: () => void;
  };
}

interface GoogleAccounts {
  oauth2: GoogleAccountsOAuth2;
}

interface Window {
  google?: {
    accounts: GoogleAccounts;
  };
}
