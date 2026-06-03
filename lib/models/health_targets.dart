import 'package:json_annotation/json_annotation.dart';

part 'health_targets.g.dart';

@JsonSerializable()
class HealthTargets {
  const HealthTargets({
    this.steps = 7000,
    this.kcal = 380.0,
    this.sleepHours = 7.0,
    this.standHours = 12,
    this.hrv = 60.0,
  });

  @JsonKey(name: 'target_steps', defaultValue: 7000)
  final int steps;

  @JsonKey(name: 'target_kcal', fromJson: _toDouble, defaultValue: 380.0)
  final double kcal;

  @JsonKey(name: 'target_sleep_hours', fromJson: _toDouble, defaultValue: 7.0)
  final double sleepHours;

  @JsonKey(name: 'target_stand_hours', defaultValue: 12)
  final int standHours;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final double hrv;

  static const defaults = HealthTargets();

  factory HealthTargets.fromJson(Map<String, dynamic> json) =>
      _$HealthTargetsFromJson(json);

  Map<String, dynamic> toJson() => _$HealthTargetsToJson(this);

  static double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
}
