import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:media_kit/media_kit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // `.env` holds shared/production values; `.env.local` (git-ignored) can
  // override for local development and takes precedence when present.
  await dotenv.load(
    fileName: '.env',
    overrideWithFiles: ['.env.local'],
    isOptional: true,
  );
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Non-fatal: builds without google-services.json (local/CI) start fine.
    // Push notification support degrades — PushNotificationService reports
    // PushAvailability.unavailable for the UI to handle gracefully.
    debugPrint('FIREBASE INIT FAILED: $e');
  }
  try {
    // Required by media_kit before any Player/VideoController is created
    // (native libs bootstrap + web wasm glue). Non-fatal if it fails.
    MediaKit.ensureInitialized();
  } catch (e) {
    debugPrint('MEDIAKIT INIT FAILED: $e');
  }
  runApp(const ProviderScope(child: BuddyUpApp()));
}
