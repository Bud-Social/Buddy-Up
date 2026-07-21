// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  emailVerified: json['emailVerified'] as bool? ?? false,
  phone: json['phone'] as String?,
  phoneVerified: json['phoneVerified'] as bool? ?? false,
  isAdult: json['isAdult'] as bool? ?? false,
  totpEnabled: json['totpEnabled'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'phone': instance.phone,
  'phoneVerified': instance.phoneVerified,
  'isAdult': instance.isAdult,
  'totpEnabled': instance.totpEnabled,
  'createdAt': instance.createdAt,
};

_TokenPair _$TokenPairFromJson(Map<String, dynamic> json) => _TokenPair(
  access: json['access'] as String,
  refresh: json['refresh'] as String,
);

Map<String, dynamic> _$TokenPairToJson(_TokenPair instance) =>
    <String, dynamic>{'access': instance.access, 'refresh': instance.refresh};
