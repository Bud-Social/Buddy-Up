import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user.dart';
import '../../data/models/profile.dart';

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final Profile? profile;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.profile,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    Profile? profile,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    _init();
    return const AuthState();
  }

  Future<void> _init() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      state = const AuthState(isAuthenticated: true, isLoading: false);
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> setTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    state = state.copyWith(isAuthenticated: true);
  }

  Future<void> setUserAndProfile(User user, Profile profile) async {
    state = state.copyWith(user: user, profile: profile);
  }

  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(profile: profile);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
