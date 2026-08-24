import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric app-lock. When enabled, the local auth prompt gates access to
/// the app (and therefore the tokens in secure storage) on every cold start.
///
/// The server never sees biometrics — this is a device-local control only.

class BiometricState {
  final bool enabled;
  final bool locked;
  final bool available; // device supports biometrics

  const BiometricState({
    this.enabled = false,
    this.locked = false,
    this.available = false,
  });

  BiometricState copyWith({bool? enabled, bool? locked, bool? available}) =>
      BiometricState(
        enabled: enabled ?? this.enabled,
        locked: locked ?? this.locked,
        available: available ?? this.available,
      );
}

class BiometricController extends Notifier<BiometricState> {
  static const _prefKey = 'biometric_lock_enabled';
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  BiometricState build() {
    _init();
    return const BiometricState();
  }

  Future<void> _init() async {
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefKey) ?? false;
    state = state.copyWith(
      available: canCheck,
      enabled: enabled && canCheck,
      // Lock immediately when the feature is on; unlocked per app session.
      locked: enabled && canCheck,
    );
  }

  Future<bool> setEnabled(bool on) async {
    if (on) {
      final ok = await _authenticate('Enable biometric lock');
      if (!ok) return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, on);
    state = state.copyWith(enabled: on, locked: on ? state.locked : false);
    return true;
  }

  /// Returns true when the user passed the local biometric check.
  Future<bool> unlock() async {
    if (!state.enabled) return true;
    if (!state.locked) return true;
    final ok = await _authenticate('Unlock BuddyUp');
    if (ok) {
      state = state.copyWith(locked: false);
    }
    return ok;
  }

  Future<void> relock() async {
    if (state.enabled) {
      state = state.copyWith(locked: true);
    }
  }

  Future<bool> _authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricProvider =
    NotifierProvider<BiometricController, BiometricState>(BiometricController.new);
