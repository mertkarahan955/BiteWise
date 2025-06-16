import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:bitewise/services/interfaces/i_nutrition_service.dart';

class NutritionService implements INutritionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<DailyIntake?> getDailyIntake(String userId, String date) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date)
        .get();
    if (doc.exists) {
      return DailyIntake.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> addMealToDailyIntake({
    required String userId,
    required String date,
    required Meal meal,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final intake = DailyIntake.fromMap(data);
      // If meal already exists, do not add again
      if (intake.mealIds.contains(meal.id)) return;
      final updated = DailyIntake(
        date: date,
        mealIds: [...intake.mealIds, meal.id],
        totalCalories: intake.totalCalories + meal.calories,
        totalProtein: intake.totalProtein + meal.protein,
        totalCarbs: intake.totalCarbs + meal.carbs,
        totalFat: intake.totalFat + meal.fat,
        totalWater: intake.totalWater,
      );
      await docRef.set(updated.toMap());
    } else {
      final newIntake = DailyIntake(
        date: date,
        mealIds: [meal.id],
        totalCalories: meal.calories,
        totalProtein: meal.protein,
        totalCarbs: meal.carbs,
        totalFat: meal.fat,
        totalWater: 0,
      );
      await docRef.set(newIntake.toMap());
    }
  }

  @override
  Future<void> addWaterToDailyIntake({
    required String userId,
    required String date,
    int amount = 1,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final intake = DailyIntake.fromMap(data);
      final updated = DailyIntake(
        date: date,
        mealIds: intake.mealIds,
        totalCalories: intake.totalCalories,
        totalProtein: intake.totalProtein,
        totalCarbs: intake.totalCarbs,
        totalFat: intake.totalFat,
        totalWater: intake.totalWater + amount,
      );
      await docRef.set(updated.toMap());
    } else {
      final newIntake = DailyIntake(
        date: date,
        mealIds: [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalWater: amount,
      );
      await docRef.set(newIntake.toMap());
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> dailyIntakeDocStream(
      String userId, String date) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date)
        .snapshots();
  }

  @override
  Future<void> setDailyIntake(
      String userId, String date, DailyIntake intake) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    await docRef.set(intake.toMap());
  }
}
