// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countdown_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CountdownTemplate _$CountdownTemplateFromJson(Map<String, dynamic> json) =>
    _CountdownTemplate(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      unit: json['unit'] as String? ?? 'days',
      defaultTarget: (json['defaultTarget'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String? ?? '📅',
      color: json['color'] as String? ?? '#6366f1',
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CountdownTemplateToJson(_CountdownTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'title': instance.title,
      'description': instance.description,
      'unit': instance.unit,
      'defaultTarget': instance.defaultTarget,
      'icon': instance.icon,
      'color': instance.color,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
    };

_UserCountdown _$UserCountdownFromJson(Map<String, dynamic> json) =>
    _UserCountdown(
      id: json['id'] as String? ?? '',
      templateId: json['templateId'] as String? ?? null,
      templateDetail: json['templateDetail'] == null
          ? null
          : CountdownTemplate.fromJson(
              json['templateDetail'] as Map<String, dynamic>,
            ),
      customReason: json['customReason'] as String? ?? '',
      countdownType: json['countdownType'] as String? ?? 'manual',
      unit: json['unit'] as String? ?? 'days',
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'] as String? ?? '',
      lastCheckinAt: json['lastCheckinAt'] as String? ?? null,
      lastAutoAdvanceAt: json['lastAutoAdvanceAt'] as String? ?? null,
      autoAdvanceSignal: json['autoAdvanceSignal'] as String? ?? null,
      isActive: json['isActive'] as bool? ?? true,
      completedAt: json['completedAt'] as String? ?? null,
      daysSinceStart: (json['daysSinceStart'] as num?)?.toInt() ?? 0,
      displayReason: json['displayReason'] as String? ?? '',
      displayIcon: json['displayIcon'] as String? ?? '📅',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$UserCountdownToJson(_UserCountdown instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
      'templateDetail': instance.templateDetail,
      'customReason': instance.customReason,
      'countdownType': instance.countdownType,
      'unit': instance.unit,
      'currentCount': instance.currentCount,
      'targetCount': instance.targetCount,
      'startDate': instance.startDate,
      'lastCheckinAt': instance.lastCheckinAt,
      'lastAutoAdvanceAt': instance.lastAutoAdvanceAt,
      'autoAdvanceSignal': instance.autoAdvanceSignal,
      'isActive': instance.isActive,
      'completedAt': instance.completedAt,
      'daysSinceStart': instance.daysSinceStart,
      'displayReason': instance.displayReason,
      'displayIcon': instance.displayIcon,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_CreateUserCountdown _$CreateUserCountdownFromJson(Map<String, dynamic> json) =>
    _CreateUserCountdown(
      templateId: json['templateId'] as String? ?? null,
      customReason: json['customReason'] as String? ?? null,
      countdownType: json['countdownType'] as String? ?? 'manual',
      unit: json['unit'] as String? ?? 'days',
      targetCount: (json['targetCount'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'] as String? ?? null,
    );

Map<String, dynamic> _$CreateUserCountdownToJson(
  _CreateUserCountdown instance,
) => <String, dynamic>{
  'templateId': instance.templateId,
  'customReason': instance.customReason,
  'countdownType': instance.countdownType,
  'unit': instance.unit,
  'targetCount': instance.targetCount,
  'startDate': instance.startDate,
};

_UpdateUserCountdown _$UpdateUserCountdownFromJson(Map<String, dynamic> json) =>
    _UpdateUserCountdown(
      customReason: json['customReason'] as String? ?? null,
      countdownType: json['countdownType'] as String? ?? null,
      unit: json['unit'] as String? ?? null,
      targetCount: (json['targetCount'] as num?)?.toInt() ?? null,
      startDate: json['startDate'] as String? ?? null,
      isActive: json['isActive'] as bool? ?? null,
    );

Map<String, dynamic> _$UpdateUserCountdownToJson(
  _UpdateUserCountdown instance,
) => <String, dynamic>{
  'customReason': instance.customReason,
  'countdownType': instance.countdownType,
  'unit': instance.unit,
  'targetCount': instance.targetCount,
  'startDate': instance.startDate,
  'isActive': instance.isActive,
};
