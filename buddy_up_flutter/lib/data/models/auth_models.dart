import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'profile.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// `POST /auth/register/`.
///
/// **There is no `role` member, and that is the contract now.**
/// `RegisterSerializer.role` used to be a `ChoiceField` over
/// `Profile.ROLE_CHOICES`, so `{"role": "trainer"}` at sign-up produced a
/// trainer and `IsVerifiedTrainer` — which checks the role and nothing else —
/// then admitted them everywhere a trainer is admitted. The server replaced it
/// with a rejecting `validate_role`: only `user` is accepted, anything else is
/// a 400 naming `CATEGORY_APPLICATION_PATH`.
///
/// So the field is gone from the payload rather than pinned to `"user"`. Sending
/// it would be dead weight the server has to validate and normalise, and a
/// field on this class is an invitation for the next form to put a chip on it
/// again. `CATEGORY_APPLICATION_PATH` below is the replacement route.
@freezed
abstract class RegisterPayload with _$RegisterPayload {
  const factory RegisterPayload({
    required String email,
    String? phone,
    required String password,
    required String dob,
    required String username,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'accepted_terms') required bool acceptedTerms,
    @JsonKey(name: 'accepted_privacy') required bool acceptedPrivacy,
    @JsonKey(name: 'accepted_guidelines') required bool acceptedGuidelines,
    @JsonKey(name: 'is_16_plus') required bool is16Plus,
    @JsonKey(name: 'guardian_name') String? guardianName,
    @JsonKey(name: 'guardian_email') String? guardianEmail,
    @JsonKey(name: 'guardian_phone') String? guardianPhone,
  }) = _RegisterPayload;

  factory RegisterPayload.fromJson(Map<String, dynamic> json) =>
      _$RegisterPayloadFromJson(json);
}

/// Where an elevated role actually comes from, named here so the register form
/// can point at a working path instead of a dead end.
///
/// The same string `RegisterSerializer.CATEGORY_APPLICATION_PATH` puts in its
/// own refusal, so the guidance a rejected caller reads and the guidance on the
/// form agree.
const String kCategoryApplicationPath = '/api/v1/verification/category-applications/';

@freezed
abstract class LoginPayload with _$LoginPayload {
  const factory LoginPayload({
    required String email,
    required String password,
    @JsonKey(name: 'remember_me') @Default(false) bool rememberMe,
    @Default(false) bool reactivate,
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

@freezed
abstract class VerifyAgeResponse with _$VerifyAgeResponse {
  const factory VerifyAgeResponse({
    @Default(0) int age,
    @Default(false) bool isAdult,
    @Default(false) bool is16Plus,
    @JsonKey(name: 'dob_hash') @Default('') String doBHash,
  }) = _VerifyAgeResponse;

  factory VerifyAgeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyAgeResponseFromJson(json);
}
