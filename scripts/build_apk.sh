#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# BuddyUp Flutter release APK builder
#
#   Usage:
#     ./scripts/build_apk.sh                  # release APK, debug-signed if no keystore
#     ./scripts/build_apk.sh --version=1.2.0 --code=42
#     APP_ENV=local ./scripts/build_apk.sh    # local-stack URLs
#
#   Requirements:
#     - Flutter SDK on PATH (>= 3.44) with Android toolchain (`flutter doctor`)
#     - android/key.properties + a release keystore (or SIGNING_* env vars) for
#       a production-signed build; otherwise falls back to debug keys.
#
#   Output: build/app/outputs/flutter-apk/app-release.apk
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

cd "$(dirname "$0")/../buddy_up_flutter"

VERSION_NAME=""
VERSION_CODE=""
DART_DEFINES=()

for arg in "$@"; do
  case "$arg" in
    --version=*) VERSION_NAME="${arg#*=}" ;;
    --code=*)    VERSION_CODE="${arg#*=}" ;;
    --local)     DART_DEFINES+=(--dart-define=APP_ENV=local) ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

echo "── Flutter version ─────────────────────────────────────────────"
flutter --version

if [ -z "${VERSION_NAME}" ] && [ -z "${VERSION_CODE}" ]; then
  echo "── Using version from pubspec.yaml (pass --version/--code to override)"
fi

GRADLE_ARGS=()
if [ -n "$VERSION_NAME" ]; then
  GRADLE_ARGS+=(--dart-define=APP_VERSION_NAME="$VERSION_NAME" -PversionName="$VERSION_NAME")
fi
if [ -n "$VERSION_CODE" ]; then
  GRADLE_ARGS+=(--dart-define=APP_VERSION_CODE="$VERSION_CODE" -PversionCode="$VERSION_CODE")
fi

echo "── pub get ────────────────────────────────────────────────────"
flutter pub get

# `.env` is git-ignored but bundled as an asset, so a clean checkout has no
# .env file and `flutter build` fails. Generate it from the committed template
# if missing (values there are safe placeholders; real secrets are injected at
# build time via --dart-define or a real `.env` file).
if [ ! -f .env ]; then
  echo "── .env not found — generating from .env.example ─────────────"
  cp .env.example .env
fi

echo "── Analyze ────────────────────────────────────────────────────"
flutter analyze

echo "── Tests ──────────────────────────────────────────────────────"
flutter test

echo "── Build release APK ──────────────────────────────────────────"
if [ -f android/key.properties ]; then
  echo "Signing: release keystore (android/key.properties)"
else
  echo "WARNING: android/key.properties not found — building with DEBUG keys."
  echo "         Set up a release keystore for Play Store production builds."
fi

flutter build apk --release \
  "${GRADLE_ARGS[@]}" \
  "${DART_DEFINES[@]}"

APK="build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "✅ Build complete: $APK"
ls -lh "$APK"

# Optionally split per-ABI APKs with --split-per-abi if you prefer Play Store
# app bundles (flutter build appbundle). For a quick sideload/distribution
# target, the single universal APK above is what you want.
