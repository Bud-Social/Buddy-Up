import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_models.dart';

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

  @POST('/auth/resend-otp/')
  Future<void> resendOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/resend-registration-otp/')
  Future<void> resendRegistrationOtp(@Body() Map<String, dynamic> body);

  @POST('/auth/totp/setup/')
  Future<TOTPSetupResponse> totpSetup();

  @POST('/auth/totp/verify/')
  Future<void> totpVerify(@Body() Map<String, dynamic> body);

  @POST('/auth/totp/disable/')
  Future<void> totpDisable(@Body() Map<String, dynamic> body);

  @POST('/auth/totp/challenge/')
  Future<TOTPChallengeResponse> totpChallenge(@Body() Map<String, dynamic> body);

  @POST('/auth/verify-age/')
  Future<VerifyAgeResponse> verifyAge(@Body() Map<String, dynamic> body);

  @POST('/auth/deactivate/')
  Future<void> deactivateAccount();

  @DELETE('/auth/delete/')
  Future<void> deleteAccount();

  @POST('/auth/export-data/')
  Future<void> exportData();
}
