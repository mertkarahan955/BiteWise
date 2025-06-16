import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/goal.dart';

enum Gender { male, female, other }

class UserModel {
  final double height;
  final double weight;
  final double targetWeight;
  final ActivityLevel activityLevel;
  final List<CommonAllergens> dietaryRestrictions;
  final List<Goal> healthGoals;
  final int dailyCalorieTarget;
  final Gender gender;
  final int age;
  final String? name;
  final String? email;

  UserModel({
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.activityLevel,
    required this.dietaryRestrictions,
    required this.healthGoals,
    required this.dailyCalorieTarget,
    required this.gender,
    required this.age,
    this.name,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel.toString(),
      'dietaryRestrictions':
          dietaryRestrictions.map((e) => e.toString()).toList(),
      'healthGoals': healthGoals.map((e) => e.toString()).toList(),
      'dailyCalorieTarget': dailyCalorieTarget,
      'gender': gender.toString(),
      'age': age,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      height: json['height']?.toDouble() ?? 0.0,
      weight: json['weight']?.toDouble() ?? 0.0,
      targetWeight: json['targetWeight']?.toDouble() ?? 0.0,
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.toString() == json['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
              ?.map((e) => CommonAllergens.values.firstWhere(
                    (a) => a.toString() == e,
                    orElse: () => CommonAllergens.gluten,
                  ))
              .toList() ??
          [],
      healthGoals: (json['healthGoals'] as List<dynamic>?)
              ?.map((e) => Goal.values.firstWhere(
                    (g) => g.toString() == e,
                    orElse: () => Goal.maintainWellness,
                  ))
              .toList() ??
          [],
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      gender: Gender.values.firstWhere(
        (e) => e.toString() == json['gender'],
        orElse: () => Gender.male,
      ),
      age: json['age'] ?? 25,
      name: json['name'],
      email: json['email'],
    );
  }

  @override
  String toString() {
    return 'UserModel(height: $height, weight: $weight, targetWeight: $targetWeight, '
        'activityLevel: $activityLevel, dietaryRestrictions: $dietaryRestrictions, '
        'healthGoals: $healthGoals, dailyCalorieTarget: $dailyCalorieTarget, '
        'gender: $gender, age: $age, name: $name, email: $email)';
  }
}
