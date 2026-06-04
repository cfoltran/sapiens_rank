import 'package:json_annotation/json_annotation.dart';

part 'habits_data.g.dart';

enum BmiFrequency { daily, monthly, quarterly }

@JsonSerializable()
class HabitsData {
  const HabitsData({
    this.heightCm,
    this.weightKg,
    this.bmiFrequency,
    this.smokes,
    this.cigarettesPerDay,
    this.drinks,
    this.drinksPerWeek,
  });

  @JsonKey(name: 'height_cm')
  final int? heightCm;

  @JsonKey(name: 'weight_kg')
  final double? weightKg;

  @JsonKey(name: 'bmi_frequency')
  final BmiFrequency? bmiFrequency;

  final bool? smokes;

  @JsonKey(name: 'cigarettes_per_day')
  final int? cigarettesPerDay;

  final bool? drinks;

  @JsonKey(name: 'drinks_per_week')
  final int? drinksPerWeek;

  double? get bmi {
    if (heightCm == null || weightKg == null) return null;
    final h = heightCm! / 100.0;
    return weightKg! / (h * h);
  }

  factory HabitsData.fromJson(Map<String, dynamic> json) =>
      _$HabitsDataFromJson(json);

  Map<String, dynamic> toJson() => _$HabitsDataToJson(this);
}
