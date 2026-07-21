import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    @Default(false) bool emailVerified,
    String? phone,
    @Default(false) bool phoneVerified,
    @Default(false) bool isAdult,
    @Default(false) bool totpEnabled,
    String? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class TokenPair with _$TokenPair {
  const factory TokenPair({
    required String access,
    required String refresh,
  }) = _TokenPair;

  factory TokenPair.fromJson(Map<String, dynamic> json) =>
      _$TokenPairFromJson(json);
}
