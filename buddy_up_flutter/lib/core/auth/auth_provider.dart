import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user.dart';
import '../../data/models/profile.dart';
import '../../data/models/auth_models.dart';

class AuthState {
  final bool isAuthenticated;
  final String? accessToken;
  final User? user;
  final Profile? profile;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.accessToken,
    this.user,
    this.profile,
    this.isLoading = true,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    User? user,
    Profile? profile,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
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
      state = AuthState(isAuthenticated: true, accessToken: token, isLoading: false);
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> setTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    state = state.copyWith(isAuthenticated: true, accessToken: access);
  }

  Future<void> setUserAndProfile(User user, Profile profile) async {
    state = state.copyWith(user: user, profile: profile);
  }

  Future<void> updateProfile(Profile profile) async {
    state = state.copyWith(profile: profile);
  }

  Future<void> handleLoginSuccess(LoginOTPResponse res) async {
    await setTokens(res.access, res.refresh);
    await setUserAndProfile(res.user, res.profile);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(isLoading: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final accessTokenProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);
  return authState.accessToken ?? '';
});
