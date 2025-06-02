import 'package:cloud_firestore/cloud_firestore.dart';

enum MealType { breakfast, lunch, dinner, snack, dessert, beverage }

enum MealCategory {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  highProtein,
  lowCarb,
  keto,
  mediterranean,
  asian,
  italian,
  mexican,
  american,
  // Add more categories as needed
}

class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealType> mealTypes;
  final List<MealCategory> categories;
  final List<String> allergens; // List of allergens this meal contains
  final bool isUserCreated;
  final String? createdBy; // User ID if user-created
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int? reviewCount;
  final bool isPublic; // Whether the meal is visible to other users

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealTypes,
    required this.categories,
    required this.allergens,
    required this.isUserCreated,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.rating,
    this.reviewCount,
    required this.isPublic,
  });

  // Convert Meal to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealTypes': mealTypes.map((e) => e.toString()).toList(),
      'categories': categories.map((e) => e.toString()).toList(),
      'allergens': allergens,
      'isUserCreated': isUserCreated,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPublic': isPublic,
    };
  }

  // Create Meal from Firestore document
  factory Meal.fromMap(String id, Map<String, dynamic> map) {
    return Meal(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      mealTypes: (map['mealTypes'] as List<dynamic>?)
              ?.map((e) => MealType.values.firstWhere(
                    (type) => type.toString() == e,
                    orElse: () => MealType.breakfast,
                  ))
              .toList() ??
          [],
      categories: (map['categories'] as List<dynamic>?)
              ?.map((e) => MealCategory.values.firstWhere(
                    (category) => category.toString() == e,
                    orElse: () => MealCategory.american,
                  ))
              .toList() ??
          [],
      allergens: List<String>.from(map['allergens'] ?? []),
      isUserCreated: map['isUserCreated'] ?? false,
      createdBy: map['createdBy'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
      isPublic: map['isPublic'] ?? false,
    );
  }

  // Create a copy of Meal with some fields updated
  Meal copyWith({
    String? name,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? instructions,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    List<MealType>? mealTypes,
    List<MealCategory>? categories,
    List<String>? allergens,
    bool? isUserCreated,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    bool? isPublic,
  }) {
    return Meal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      mealTypes: mealTypes ?? this.mealTypes,
      categories: categories ?? this.categories,
      allergens: allergens ?? this.allergens,
      isUserCreated: isUserCreated ?? this.isUserCreated,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
