import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_models.dart';
import '../models/device_session.dart';

part 'auth_repository.g.dart';

@RestApi()
abstract class AuthRepository {
  factory AuthRepository(Dio dio, {String baseUrl}) = _AuthRepository;

  @POST('/auth/register/')
  Future<RegisterResponse> register(@Body() RegisterPayload payload);

  @POST('/auth/verify-registration-otp/')
  Future<LoginOTPResponse> verifyRegistrationOtp(
    @Body() RegistrationOTPSerializer payload,
  );

  @POST('/auth/login/')
  Future<LoginInitResponse> login(@Body() LoginPayload payload);

  @POST('/auth/google/')
  Future<LoginOTPResponse> googleLogin(@Body() Map<String, dynamic> payload);

  @POST('/auth/apple/')
  Future<LoginOTPResponse> appleLogin(@Body() Map<String, dynamic> payload);

  @POST('/auth/verify-login-otp/')
  Future<LoginOTPResponse> verifyLoginOtp(@Body() LoginOTPSerializer payload);

  @POST('/auth/token/refresh/')
  Future<dynamic> refreshToken(@Body() Map<String, dynamic> body);

  @POST('/auth/logout/')
  Future<void> logout();

  @POST('/auth/forgot-password/')
  Future<void> forgotPassword(@Body() PasswordResetRequest payload);

  @POST('/auth/reset-password/')
  Future<void> resetPassword(@Body() PasswordResetConfirm payload);

  @POST('/auth/change-password/')
  Future<void> changePassword(@Body() ChangePasswordPayload payload);

  @GET('/auth/set-password/')
  Future<dynamic> passwordStatus();

  @POST('/auth/set-password/')
  Future<void> setPassword(@Body() Map<String, dynamic> payload);

  @POST('/auth/resend-otp/')
  Future<void> resendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/resend-registration-otp/')
  Future<void> resendRegistrationOtp(@Body() Map<String, dynamic> body);

  /// A staff member who cannot yet hold a session enrols with this credential.
  ///
  /// Null in the ordinary case: an already-signed-in operator enrolling a second
  /// device sends nothing and authenticates with the normal access token. The
  /// server accepts it only on these two endpoints and only before TOTP is on.
  @POST('/auth/totp/setup/')
  Future<TOTPSetupResponse> totpSetup(
      {@Header('X-TOTP-Enrolment-Token') String? enrolmentToken});

  @POST('/auth/totp/verify/')
  Future<void> totpVerify(@Body() Map<String, dynamic> body,
      {@Header('X-TOTP-Enrolment-Token') String? enrolmentToken});

  @POST('/auth/totp/disable/')
  Future<void> totpDisable(@Body() Map<String, dynamic> body);

  @POST('/auth/totp/challenge/')
  Future<TOTPChallengeResponse> totpChallenge(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-age/')
  Future<VerifyAgeResponse> verifyAge(@Body() Map<String, dynamic> body);

  @POST('/auth/deactivate/')
  Future<void> deactivateAccount();

  /// Backend contract: POST (not DELETE) with
  /// {confirm: 'delete my account', current_password} or {totp_code}.
  @POST('/auth/delete/')
  Future<void> deleteAccount(@Body() Map<String, dynamic> payload);

  @POST('/auth/export-data/')
  Future<void> exportData();

  /// {ready: bool, created_at: String?, filename: String?}
  @GET('/auth/export-data/status/')
  Future<dynamic> exportDataStatus();

  @GET('/auth/consent-status/')
  Future<dynamic> consentStatus();

  // ── Device sessions ────────────────────────────────────────────────────────
  // The client sends X-Device-Id (see ApiClient) so the backend can
  // attribute each login to a device.

  @GET('/auth/sessions/')
  Future<List<DeviceSession>> listSessions();

  @DELETE('/auth/sessions/{id}/')
  Future<void> revokeSession(@Path('id') int sessionId);

  @POST('/auth/logout-all/')
  Future<void> logoutAllDevices();
}
