export type AndroidAbi = 'arm64-v8a' | 'armeabi-v7a' | 'x86_64';

/**
 * GitHub resolves this route to the asset on the newest published release.
 * Keeping the ABI in the filename lets the landing page select a compatible
 * split APK without hard-coding a release tag or shipping a large universal APK.
 */
const GITHUB_RELEASE_DOWNLOAD_BASE =
  'https://github.com/Bud-Social/Buddy-Up/releases/latest/download';

export const ANDROID_APK_URLS: Record<AndroidAbi, string> = {
  'arm64-v8a': `${GITHUB_RELEASE_DOWNLOAD_BASE}/app-arm64-v8a-release.apk`,
  'armeabi-v7a': `${GITHUB_RELEASE_DOWNLOAD_BASE}/app-armeabi-v7a-release.apk`,
  x86_64: `${GITHUB_RELEASE_DOWNLOAD_BASE}/app-x86_64-release.apk`,
};

function fromArchitecture(architecture: string | undefined): AndroidAbi | null {
  const value = (architecture || '').toLowerCase();
  if (value.includes('arm64') || value.includes('aarch64')) return 'arm64-v8a';
  if (value.includes('arm') || value.includes('armv7')) return 'armeabi-v7a';
  if (value.includes('x86_64') || value.includes('amd64')) return 'x86_64';
  return null;
}

/** Best-effort synchronous ABI detection used before userAgentData resolves. */
export function detectAndroidAbi(): AndroidAbi {
  if (typeof navigator === 'undefined') return 'arm64-v8a';
  const userAgent = navigator.userAgent || '';
  return (
    fromArchitecture(userAgent) ||
    (userAgent.includes('Android') ? 'arm64-v8a' : 'arm64-v8a')
  );
}

export function getAndroidApkUrl(abi: AndroidAbi = detectAndroidAbi()): string {
  return ANDROID_APK_URLS[abi];
}

// Retained for existing imports; it now follows the newest release and uses
// the most common Android ABI until a device-specific value is available.
export const GITHUB_RELEASE_APK_URL = getAndroidApkUrl();

export const APP_DOWNLOAD_URLS = {
  androidApk: GITHUB_RELEASE_APK_URL,
  appStore: '#',
  googlePlay: '#',
};

export const APP_URL = '/';
export const PWA_ENABLED = true;
