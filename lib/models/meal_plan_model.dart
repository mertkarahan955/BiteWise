import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanDayEntry {
  final String mealType; // "breakfast", "lunch", "dinner"
  final String mealId;

  MealPlanDayEntry({required this.mealType, required this.mealId});

  factory MealPlanDayEntry.fromMap(Map<String, dynamic> map) =>
      MealPlanDayEntry(
        mealType: map['mealType'],
        mealId: map['mealId'],
      );
}

class MealPlanDay {
  final String dayOfWeek;
  final List<MealPlanDayEntry> meals;

  MealPlanDay({required this.dayOfWeek, required this.meals});

  factory MealPlanDay.fromMap(Map<String, dynamic> map) => MealPlanDay(
        dayOfWeek: map['dayOfWeek'],
        meals: (map['meals'] as List)
            .map((e) => MealPlanDayEntry.fromMap(e))
            .toList(),
      );
}

class MealPlan {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final List<MealPlanDay> days;

  MealPlan({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.days,
  });

  factory MealPlan.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealPlan(
      id: doc.id,
      name: data['name'],
      userId: data['userId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      days: (data['days'] as List).map((e) => MealPlanDay.fromMap(e)).toList(),
    );
  }
}
