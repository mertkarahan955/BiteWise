import 'package:bitewise/models/meal_model.dart';

class HomeData {
  final String userName;
  final String profileImageUrl;
  final int dailyCalories;
  final int calorieGoal;
  final int waterDrank;
  final int waterGoal;
  final List<int> weeklyProgress;
  final MealOfTheDay mealOfTheDay;
  final WeatherBanner weatherBanner;
  final int mealsEatenToday;

  HomeData({
    required this.userName,
    required this.profileImageUrl,
    required this.dailyCalories,
    required this.calorieGoal,
    required this.waterDrank,
    required this.waterGoal,
    required this.weeklyProgress,
    required this.mealOfTheDay,
    required this.weatherBanner,
    required this.mealsEatenToday,
  });

  factory HomeData.fromMap(Map<String, dynamic> map) {
    return HomeData(
      userName: map['userName'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      dailyCalories: map['dailyCalories'] ?? 0,
      calorieGoal: map['calorieGoal'] ?? 0,
      waterDrank: map['waterDrank'] ?? 0,
      waterGoal: map['waterGoal'] ?? 0,
      weeklyProgress: List<int>.from(map['weeklyProgress'] ?? []),
      mealOfTheDay: MealOfTheDay.fromMap(map['mealOfTheDay'] ?? {}),
      weatherBanner: WeatherBanner.fromMap(map['weatherBanner'] ?? {}),
      mealsEatenToday: map['mealsEatenToday'] ?? 0,
    );
  }
}

class MealOfTheDay {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealType> mealTypes;
  final List<MealCategory> categories;
  final List<String> allergens;
  final bool isUserCreated;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int? reviewCount;
  final bool isPublic;

  MealOfTheDay({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.ingredients = const [],
    this.instructions = const [],
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.mealTypes = const [],
    this.categories = const [],
    this.allergens = const [],
    this.isUserCreated = false,
    this.createdBy,
    DateTime? createdAt,
    this.updatedAt,
    this.rating,
    this.reviewCount,
    this.isPublic = true,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MealOfTheDay.fromMap(Map<String, dynamic> map) {
    return MealOfTheDay(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      mealTypes: (map['mealTypes'] as List<dynamic>?)
              ?.map((e) => MealType.values.firstWhere(
                  (type) => type.toString() == e,
                  orElse: () => MealType.breakfast))
              .toList() ??
          [],
      categories: (map['categories'] as List<dynamic>?)
              ?.map((e) => MealCategory.values.firstWhere(
                  (cat) => cat.toString() == e,
                  orElse: () => MealCategory.american))
              .toList() ??
          [],
      allergens: List<String>.from(map['allergens'] ?? []),
      isUserCreated: map['isUserCreated'] ?? false,
      createdBy: map['createdBy'],
      createdAt:
          map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now(),
      updatedAt: map['updatedAt'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
      isPublic: map['isPublic'] ?? true,
    );
  }

  Meal toMeal() {
    return Meal(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      ingredients: ingredients,
      instructions: instructions,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealTypes: mealTypes,
      categories: categories,
      allergens: allergens,
      isUserCreated: isUserCreated,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      rating: rating,
      reviewCount: reviewCount,
      isPublic: isPublic,
    );
  }
}

class WeatherBanner {
  final String weatherType;
  final String suggestionText;
  final String? suggestedMealId;

  WeatherBanner({
    required this.weatherType,
    required this.suggestionText,
    this.suggestedMealId,
  });

  factory WeatherBanner.fromMap(Map<String, dynamic> map) {
    return WeatherBanner(
      weatherType: map['weatherType'] ?? '',
      suggestionText: map['suggestionText'] ?? '',
      suggestedMealId: map['suggestedMealId'],
    );
  }
}
