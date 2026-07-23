import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'profile.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class RegisterPayload with _$RegisterPayload {
  const factory RegisterPayload({
    required String email,
    String? phone,
    required String password,
    required String dob,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    required String role,
    @JsonKey(name: 'accepted_terms') required bool acceptedTerms,
    @JsonKey(name: 'accepted_privacy') required bool acceptedPrivacy,
    @JsonKey(name: 'accepted_guidelines') required bool acceptedGuidelines,
    @JsonKey(name: 'is_16_plus') required bool is16Plus,
  }) = _RegisterPayload;

  factory RegisterPayload.fromJson(Map<String, dynamic> json) =>
      _$RegisterPayloadFromJson(json);
}

@freezed
abstract class LoginPayload with _$LoginPayload {
  const factory LoginPayload({
    required String email,
    required String password,
    @JsonKey(name: 'remember_me') @Default(false) bool rememberMe,
  }) = _LoginPayload;

  factory LoginPayload.fromJson(Map<String, dynamic> json) =>
      _$LoginPayloadFromJson(json);
}

@freezed
abstract class LoginInitResponse with _$LoginInitResponse {
  const factory LoginInitResponse({
    @JsonKey(name: 'require_otp') required bool requireOtp,
    @JsonKey(name: 'login_token') required String loginToken,
    @JsonKey(name: 'masked_email') required String maskedEmail,
  }) = _LoginInitResponse;

  factory LoginInitResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginInitResponseFromJson(json);
}

@freezed
abstract class LoginOTPResponse with _$LoginOTPResponse {
  const factory LoginOTPResponse({
    required String access,
    required String refresh,
    required User user,
    required Profile profile,
    @JsonKey(name: 'new_device') @Default(false) bool newDevice,
  }) = _LoginOTPResponse;

  factory LoginOTPResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginOTPResponseFromJson(json);
}

@freezed
abstract class RegisterResponse with _$RegisterResponse {
  const factory RegisterResponse({
    @JsonKey(name: 'registration_token') required String registrationToken,
    required String email,
    @JsonKey(name: 'user_id') required String userId,
    required String message,
  }) = _RegisterResponse;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}

@freezed
abstract class TOTPSetupResponse with _$TOTPSetupResponse {
  const factory TOTPSetupResponse({
    required String secret,
    @JsonKey(name: 'provisioning_uri') required String provisioningUri,
    @JsonKey(name: 'qr_code') required String qrCode,
  }) = _TOTPSetupResponse;

  factory TOTPSetupResponse.fromJson(Map<String, dynamic> json) =>
      _$TOTPSetupResponseFromJson(json);
}

@freezed
abstract class TOTPChallengeInitResponse with _$TOTPChallengeInitResponse {
  const factory TOTPChallengeInitResponse({
    @JsonKey(name: 'require_totp') required bool requireTotp,
    @JsonKey(name: 'temp_token') required String tempToken,
  }) = _TOTPChallengeInitResponse;

  factory TOTPChallengeInitResponse.fromJson(Map<String, dynamic> json) =>
      _$TOTPChallengeInitResponseFromJson(json);
}

@freezed
abstract class TOTPChallengeResponse with _$TOTPChallengeResponse {
  const factory TOTPChallengeResponse({
    required String access,
    required String refresh,
    required User user,
    required Profile profile,
  }) = _TOTPChallengeResponse;

  factory TOTPChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$TOTPChallengeResponseFromJson(json);
}

@freezed
abstract class OTPSerializer with _$OTPSerializer {
  const factory OTPSerializer({
    required String otp,
    String? channel,
  }) = _OTPSerializer;

  factory OTPSerializer.fromJson(Map<String, dynamic> json) =>
      _$OTPSerializerFromJson(json);
}

@freezed
abstract class RegistrationOTPSerializer with _$RegistrationOTPSerializer {
  const factory RegistrationOTPSerializer({
    required String registrationToken,
    required String otp,
  }) = _RegistrationOTPSerializer;

  factory RegistrationOTPSerializer.fromJson(Map<String, dynamic> json) =>
      _$RegistrationOTPSerializerFromJson(json);
}

@freezed
abstract class LoginOTPSerializer with _$LoginOTPSerializer {
  const factory LoginOTPSerializer({
    required String loginToken,
    required String otp,
    @Default(false) bool rememberMe,
  }) = _LoginOTPSerializer;

  factory LoginOTPSerializer.fromJson(Map<String, dynamic> json) =>
      _$LoginOTPSerializerFromJson(json);
}

@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  const factory PasswordResetRequest({
    required String email,
  }) = _PasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
}

@freezed
abstract class PasswordResetConfirm with _$PasswordResetConfirm {
  const factory PasswordResetConfirm({
    required String token,
    required String newPassword,
  }) = _PasswordResetConfirm;

  factory PasswordResetConfirm.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetConfirmFromJson(json);
}

@freezed
abstract class ChangePasswordPayload with _$ChangePasswordPayload {
  const factory ChangePasswordPayload({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordPayload;

  factory ChangePasswordPayload.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordPayloadFromJson(json);
}
