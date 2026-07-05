/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_WS_BASE_URL: string;
  readonly VITE_AGORA_APP_ID: string;
  readonly VITE_GOOGLE_MAPS_KEY: string;
  readonly VITE_CLOUDINARY_CLOUD_NAME: string;
  readonly VITE_FIREBASE_CONFIG: string;
  readonly VITE_FLUTTERWAVE_PUBLIC_KEY: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

interface FlutterwaveCheckoutConfig {
  public_key: string;
  tx_ref: string;
  amount: number;
  currency: string;
  payment_options: string;
  customer: {
    email: string;
    phone_number?: string;
    name: string;
  };
  callback: (response: { transaction_id: string; tx_ref: string; status: string }) => void;
  onclose: () => void;
  customizations: {
    title: string;
    description: string;
    logo: string;
  };
}

interface Window {
  FlutterwaveCheckout: (config: FlutterwaveCheckoutConfig) => void;
}
