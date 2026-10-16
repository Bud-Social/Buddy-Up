import 'package:buddy_up_flutter/features/auth/totp_enrolment_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A 403 shaped the way the server sends it: the envelope carries `code`, and
/// the actionable payload sits under `data`.
DioException _mfaResponse({required String code, Object? enrolmentToken}) {
  const path = '/api/v1/auth/verify-login-otp/';
  return DioException(
    requestOptions: RequestOptions(path: path),
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 403,
      data: {
        'success': false,
        'code': code,
        'message': 'Two-factor authentication is required for staff accounts.',
        'data': {
          'code': code,
          'email': 'staff@example.com',
          'enrolment_token': ?enrolmentToken,
        },
      },
    ),
  );
}

void main() {
  group('TOTP enrolment credential state', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(totpEnrolmentProvider);
      expect(state.token, isNull);
      expect(state.hasToken, isFalse);
    });

    test('holds a token once set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(totpEnrolmentProvider.notifier).setToken('enrol-abc');

      expect(container.read(totpEnrolmentProvider).token, 'enrol-abc');
      expect(container.read(totpEnrolmentProvider).hasToken, isTrue);
    });

    test('clear() drops it, so a spent credential is not left in memory', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(totpEnrolmentProvider.notifier).setToken('enrol-abc');
      container.read(totpEnrolmentProvider.notifier).clear();

      expect(container.read(totpEnrolmentProvider).token, isNull);
      expect(container.read(totpEnrolmentProvider).hasToken, isFalse);
    });

    test('an empty string never counts as a credential', () {
      // The login screen treats an empty token as "no enrolment offered" and
      // stays put. The state has to agree, or the two disagree about whether
      // there is anything to send.
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(totpEnrolmentProvider.notifier).setToken('');

      expect(container.read(totpEnrolmentProvider).hasToken, isFalse);
    });
  });

  group('reading the credential out of a 403', () {
    test('returns the token the server sent', () {
      expect(
        totpEnrolmentTokenFrom(_mfaResponse(
          code: 'mfa_enrolment_required',
          enrolmentToken: 'enrol-abc',
        )),
        'enrol-abc',
      );
    });

    test('returns null when the code came with no token', () {
      // Navigating on the code alone would land on a setup screen that can only
      // 401. Null keeps the user where they are with a real error.
      expect(
        totpEnrolmentTokenFrom(_mfaResponse(code: 'mfa_enrolment_required')),
        isNull,
      );
    });

    test('returns null for an unrelated 403', () {
      expect(
        totpEnrolmentTokenFrom(_mfaResponse(
          code: 'something_else',
          enrolmentToken: 'enrol-abc',
        )),
        isNull,
      );
    });

    test('returns null for a non-Dio error', () {
      expect(totpEnrolmentTokenFrom(Exception('boom')), isNull);
      expect(totpEnrolmentTokenFrom('a string'), isNull);
    });

    test('returns null when the body is not a map', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 403,
          data: 'plain text',
        ),
      );
      expect(totpEnrolmentTokenFrom(err), isNull);
    });
  });

  group('the enrolment header name', () {
    test('matches what the backend reads', () {
      // The Django constant is 'HTTP_X_TOTP_ENROLMENT_TOKEN', which Django
      // exposes as X-TOTP-Enrolment-Token. Retrofit demands a literal in the
      // annotation, so this pairing is the only thing tying the two together.
      expect(totpEnrolmentHeaderName, 'X-TOTP-Enrolment-Token');
    });
  });
}