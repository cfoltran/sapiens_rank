// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_targets.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthTargets _$HealthTargetsFromJson(Map<String, dynamic> json) =>
    HealthTargets(
      steps: (json['target_steps'] as num?)?.toInt() ?? 7000,
      kcal: json['target_kcal'] == null
          ? 380.0
          : HealthTargets._toDouble(json['target_kcal']),
      sleepHours: json['target_sleep_hours'] == null
          ? 7.0
          : HealthTargets._toDouble(json['target_sleep_hours']),
      standHours: (json['target_stand_hours'] as num?)?.toInt() ?? 12,
    );

Map<String, dynamic> _$HealthTargetsToJson(HealthTargets instance) =>
    <String, dynamic>{
      'target_steps': instance.steps,
      'target_kcal': instance.kcal,
      'target_sleep_hours': instance.sleepHours,
      'target_stand_hours': instance.standHours,
    };
