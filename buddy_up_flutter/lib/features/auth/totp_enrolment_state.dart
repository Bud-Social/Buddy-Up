import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Short-lived credential that lets a staff member enrol two-factor
/// authentication while they are *not* allowed a session.
///
/// Staff must have 2FA; until they do, the server refuses to mint them tokens.
/// But the enrolment endpoints are authenticated, so refusing the session also
/// refuses the enrolment, and a staff account created before the requirement
/// existed has no way in at all. The server hands this credential back once the
/// email OTP has been verified -- that OTP is the identity proof, and it is why
/// this is not simply "the password gets you enrolment".
///
/// Deliberately in memory and never persisted: it lives ten minutes, authorises
/// exactly two endpoints, and is refused the moment TOTP is switched on.
/// Persisting it would store a credential with no benefit and a real cost.
class TotpEnrolmentState {
  final String? token;

  const TotpEnrolmentState({this.token});

  bool get hasToken => token != null && token!.isNotEmpty;

  TotpEnrolmentState copyWith({String? token, bool clear = false}) {
    if (clear) return const TotpEnrolmentState();
    return TotpEnrolmentState(token: token ?? this.token);
  }
}

class TotpEnrolmentNotifier extends Notifier<TotpEnrolmentState> {
  @override
  TotpEnrolmentState build() => const TotpEnrolmentState();

  void setToken(String token) => state = state.copyWith(token: token);

  /// Called the moment enrolment succeeds. The server refuses the credential
  /// from then on, so keeping it would only leave a stale secret in memory.
  void clear() => state = const TotpEnrolmentState();
}

final totpEnrolmentProvider =
    NotifierProvider<TotpEnrolmentNotifier, TotpEnrolmentState>(
  TotpEnrolmentNotifier.new,
);

/// Wire name for the enrolment credential.
///
/// Duplicated as a literal inside the retrofit `@Header` annotations because the
/// generator requires a compile-time constant string, so this is the readable
/// counterpart rather than the value actually sent. It must stay equal to
/// `common.authentication.TOTP_ENROLMENT_HEADER` on the server.
const String totpEnrolmentHeaderName = 'X-TOTP-Enrolment-Token';

/// The enrolment credential carried by a 403, or null when this is any other
/// failure.
///
/// Returns null when the code is present but no token came with it, so a
/// caller never navigates to a setup screen that could only fail 401. Lives
/// here rather than on the login screen so it can be tested without a widget.
String? totpEnrolmentTokenFrom(Object error) {
  if (error is! DioException) return null;
  final body = error.response?.data;
  if (body is! Map) return null;
  final inner = body['data'];
  if (inner is! Map) return null;
  if (inner['code'] != 'mfa_enrolment_required') return null;
  final token = inner['enrolment_token'];
  return (token is String && token.isNotEmpty) ? token : null;
}
