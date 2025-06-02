import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/goal.dart';

class UserModel {
  final String? name;
  final String? email;
  final double height;
  final double weight;
  final ActivityLevel activityLevel;
  final List<CommonAllergens> dietaryRestrictions; // common allergens
  final List<Goal> healthGoals;
  final int dailyCalorieTarget;

  UserModel({
    this.name,
    this.email,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.dietaryRestrictions,
    required this.healthGoals,
    required this.dailyCalorieTarget,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel.toString().split('.').last,
      'dietaryRestrictions':
          dietaryRestrictions.map((e) => e.toString().split('.').last).toList(),
      'healthGoals':
          healthGoals.map((e) => e.toString().split('.').last).toList(),
      'dailyCalorieTarget': dailyCalorieTarget,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      height: (json['height'] as num?)?.toDouble() ?? 170.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.toString() == json['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      dietaryRestrictions: (json['dietaryRestrictions'] as List?)
              ?.map((e) => CommonAllergens.values.firstWhere(
                    (a) => a.toString() == e,
                    orElse: () => CommonAllergens.gluten,
                  ))
              .toList() ??
          [],
      healthGoals: (json['healthGoals'] as List?)
              ?.map((e) => Goal.values.firstWhere(
                    (g) => g.toString() == e,
                    orElse: () => Goal.loseWeight,
                  ))
              .toList() ??
          [],
      dailyCalorieTarget: json['dailyCalorieTarget'] as int? ?? 2000,
    );
  }
}
