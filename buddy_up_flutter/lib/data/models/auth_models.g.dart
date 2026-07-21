// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterPayload _$RegisterPayloadFromJson(Map<String, dynamic> json) =>
    _RegisterPayload(
      email: json['email'] as String,
      phone: json['phone'] as String?,
      password: json['password'] as String,
      dob: json['dob'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      acceptedTerms: json['acceptedTerms'] as bool,
      acceptedPrivacy: json['acceptedPrivacy'] as bool,
      acceptedGuidelines: json['acceptedGuidelines'] as bool,
      is16Plus: json['is16Plus'] as bool,
    );

Map<String, dynamic> _$RegisterPayloadToJson(_RegisterPayload instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'password': instance.password,
      'dob': instance.dob,
      'username': instance.username,
      'displayName': instance.displayName,
      'role': instance.role,
      'acceptedTerms': instance.acceptedTerms,
      'acceptedPrivacy': instance.acceptedPrivacy,
      'acceptedGuidelines': instance.acceptedGuidelines,
      'is16Plus': instance.is16Plus,
    };

_LoginPayload _$LoginPayloadFromJson(Map<String, dynamic> json) =>
    _LoginPayload(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginPayloadToJson(_LoginPayload instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'rememberMe': instance.rememberMe,
    };

_LoginInitResponse _$LoginInitResponseFromJson(Map<String, dynamic> json) =>
    _LoginInitResponse(
      requireOtp: json['requireOtp'] as bool,
      loginToken: json['loginToken'] as String,
      maskedEmail: json['maskedEmail'] as String,
    );

Map<String, dynamic> _$LoginInitResponseToJson(_LoginInitResponse instance) =>
    <String, dynamic>{
      'requireOtp': instance.requireOtp,
      'loginToken': instance.loginToken,
      'maskedEmail': instance.maskedEmail,
    };

_LoginOTPResponse _$LoginOTPResponseFromJson(Map<String, dynamic> json) =>
    _LoginOTPResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
      newDevice: json['newDevice'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginOTPResponseToJson(_LoginOTPResponse instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user,
      'profile': instance.profile,
      'newDevice': instance.newDevice,
    };

_RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    _RegisterResponse(
      registrationToken: json['registrationToken'] as String,
      email: json['email'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RegisterResponseToJson(_RegisterResponse instance) =>
    <String, dynamic>{
      'registrationToken': instance.registrationToken,
      'email': instance.email,
      'userId': instance.userId,
      'message': instance.message,
    };

_TOTPSetupResponse _$TOTPSetupResponseFromJson(Map<String, dynamic> json) =>
    _TOTPSetupResponse(
      secret: json['secret'] as String,
      provisioningUri: json['provisioningUri'] as String,
      qrCode: json['qrCode'] as String,
    );

Map<String, dynamic> _$TOTPSetupResponseToJson(_TOTPSetupResponse instance) =>
    <String, dynamic>{
      'secret': instance.secret,
      'provisioningUri': instance.provisioningUri,
      'qrCode': instance.qrCode,
    };

_TOTPChallengeInitResponse _$TOTPChallengeInitResponseFromJson(
  Map<String, dynamic> json,
) => _TOTPChallengeInitResponse(
  requireTotp: json['requireTotp'] as bool,
  tempToken: json['tempToken'] as String,
);

Map<String, dynamic> _$TOTPChallengeInitResponseToJson(
  _TOTPChallengeInitResponse instance,
) => <String, dynamic>{
  'requireTotp': instance.requireTotp,
  'tempToken': instance.tempToken,
};

_TOTPChallengeResponse _$TOTPChallengeResponseFromJson(
  Map<String, dynamic> json,
) => _TOTPChallengeResponse(
  access: json['access'] as String,
  refresh: json['refresh'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TOTPChallengeResponseToJson(
  _TOTPChallengeResponse instance,
) => <String, dynamic>{
  'access': instance.access,
  'refresh': instance.refresh,
  'user': instance.user,
  'profile': instance.profile,
};

_OTPSerializer _$OTPSerializerFromJson(Map<String, dynamic> json) =>
    _OTPSerializer(
      otp: json['otp'] as String,
      channel: json['channel'] as String?,
    );

Map<String, dynamic> _$OTPSerializerToJson(_OTPSerializer instance) =>
    <String, dynamic>{'otp': instance.otp, 'channel': instance.channel};

_RegistrationOTPSerializer _$RegistrationOTPSerializerFromJson(
  Map<String, dynamic> json,
) => _RegistrationOTPSerializer(
  registrationToken: json['registrationToken'] as String,
  otp: json['otp'] as String,
);

Map<String, dynamic> _$RegistrationOTPSerializerToJson(
  _RegistrationOTPSerializer instance,
) => <String, dynamic>{
  'registrationToken': instance.registrationToken,
  'otp': instance.otp,
};

_LoginOTPSerializer _$LoginOTPSerializerFromJson(Map<String, dynamic> json) =>
    _LoginOTPSerializer(
      loginToken: json['loginToken'] as String,
      otp: json['otp'] as String,
      rememberMe: json['rememberMe'] as bool? ?? false,
    );

Map<String, dynamic> _$LoginOTPSerializerToJson(_LoginOTPSerializer instance) =>
    <String, dynamic>{
      'loginToken': instance.loginToken,
      'otp': instance.otp,
      'rememberMe': instance.rememberMe,
    };

_PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordResetRequest(email: json['email'] as String);

Map<String, dynamic> _$PasswordResetRequestToJson(
  _PasswordResetRequest instance,
) => <String, dynamic>{'email': instance.email};

_PasswordResetConfirm _$PasswordResetConfirmFromJson(
  Map<String, dynamic> json,
) => _PasswordResetConfirm(
  token: json['token'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$PasswordResetConfirmToJson(
  _PasswordResetConfirm instance,
) => <String, dynamic>{
  'token': instance.token,
  'newPassword': instance.newPassword,
};

_ChangePasswordPayload _$ChangePasswordPayloadFromJson(
  Map<String, dynamic> json,
) => _ChangePasswordPayload(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$ChangePasswordPayloadToJson(
  _ChangePasswordPayload instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
