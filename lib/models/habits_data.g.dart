// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitsData _$HabitsDataFromJson(Map<String, dynamic> json) => HabitsData(
  heightCm: (json['height_cm'] as num?)?.toInt(),
  weightKg: (json['weight_kg'] as num?)?.toDouble(),
  bmiFrequency: $enumDecodeNullable(
    _$BmiFrequencyEnumMap,
    json['bmi_frequency'],
  ),
  smokes: json['smokes'] as bool?,
  cigarettesPerDay: (json['cigarettes_per_day'] as num?)?.toInt(),
  drinks: json['drinks'] as bool?,
  drinksPerWeek: (json['drinks_per_week'] as num?)?.toInt(),
);

Map<String, dynamic> _$HabitsDataToJson(HabitsData instance) =>
    <String, dynamic>{
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
      'bmi_frequency': _$BmiFrequencyEnumMap[instance.bmiFrequency],
      'smokes': instance.smokes,
      'cigarettes_per_day': instance.cigarettesPerDay,
      'drinks': instance.drinks,
      'drinks_per_week': instance.drinksPerWeek,
    };

const _$BmiFrequencyEnumMap = {
  BmiFrequency.daily: 'daily',
  BmiFrequency.monthly: 'monthly',
  BmiFrequency.quarterly: 'quarterly',
};
