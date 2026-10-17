import 'dart:convert';

import 'package:buddy_up_flutter/core/api/api_error.dart';
import 'package:buddy_up_flutter/data/models/auth_models.dart';
import 'package:buddy_up_flutter/features/auth/totp_enrolment_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parsing, not networking: the interesting failure here is that a *challenge*
/// payload has no tokens, and the model used to require them.
///
/// Before this change `LoginOTPResponse` declared `access`, `refresh`, `user`
/// and `profile` as required, so any challenge response failed to deserialize
/// and the caller threw a type error before it could branch on the challenge. The
/// social-login OTP step and the staff-enrolment step both live behind that
/// branch, so both were unreachable on this client.
void main() {
  group('LoginOTPResponse', () {
    test('parses a completed login', () {
      final res = LoginOTPResponse.fromJson(jsonDecode('''
      {
        "access": "a", "refresh": "r",
        "user": {"id": "u1", "email": "a@b.com"},
        "profile": {"user_id": "u1", "username": "a", "display_name": "A"}
      }
      '''));

      expect(res.isComplete, isTrue);
      expect(res.access, 'a');
      expect(res.user!.totpEnabled, isFalse);
    });

    test('parses a staff-enrolment OTP challenge with no tokens', () {
      final res = LoginOTPResponse.fromJson(jsonDecode('''
      {
        "require_otp": true,
        "login_token": "lt",
        "masked_email": "sta***@b.com",
        "mfa_enrolment_pending": true
      }
      '''));

      expect(res.isComplete, isFalse);
      expect(res.requireOtp, isTrue);
      expect(res.loginToken, 'lt');
      expect(res.mfaEnrolmentPending, isTrue);
    });

    test('parses a TOTP challenge with no tokens', () {
      final res = LoginOTPResponse.fromJson(jsonDecode('''
      {"require_totp": true, "temp_token": "tt"}
      '''));

      expect(res.isComplete, isFalse);
      expect(res.requireTotp, isTrue);
      expect(res.tempToken, 'tt');
    });

    test('an incomplete response is never mistaken for a session', () {
      // The dangerous shape: a caller that skips the isComplete check would
      // store null tokens and set isAuthenticated, i.e. a "logged in" user with
      // no credentials at all.
      final res = LoginOTPResponse.fromJson(jsonDecode('{"require_otp": true}'));

      expect(res.isComplete, isFalse);
      expect(res.access, isNull);
      expect(res.refresh, isNull);
      expect(res.user, isNull);
      expect(res.profile, isNull);
    });
  });

  group('enrolment credential from a 403', () {
    DioException forbidden(Object inner) {
      const path = '/api/v1/auth/verify-registration-otp/';
      return DioException(
        requestOptions: RequestOptions(path: path),
        response: Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 403,
          data: {
            'success': false,
            'code': 'mfa_enrolment_required',
            'message': 'Two-factor authentication is required for staff accounts.',
            'data': inner,
          },
        ),
      );
    }

    test('returns the token the server sent', () {
      expect(
        totpEnrolmentTokenFrom(forbidden({
          'code': 'mfa_enrolment_required',
          'enrolment_token': 'enrol-abc',
        })),
        'enrol-abc',
      );
    });

    test('returns null when the code came without a token', () {
      expect(
        totpEnrolmentTokenFrom(forbidden({'code': 'mfa_enrolment_required'})),
        isNull,
      );
    });
  });

  group('state handoff', () {
    test('stores then clears', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(totpEnrolmentProvider.notifier).setToken('enrol-abc');
      expect(container.read(totpEnrolmentProvider).hasToken, isTrue);

      container.read(totpEnrolmentProvider.notifier).clear();
      expect(container.read(totpEnrolmentProvider).hasToken, isFalse);
    });
  });

  group('message honesty', () {
    test('the error helper does not invent an MFA wording for other failures', () {
      final generic = DioException(
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 400,
          data: {'message': 'Invalid OTP code.'},
        ),
      );

      expect(apiErrorMessage(generic), contains('Invalid OTP code'));
      expect(apiErrorMessage(generic), isNot(contains('two-factor')));
    });
  });
}