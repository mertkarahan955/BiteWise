import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class INutritionService {
  User? get currentUser;
  Future<DailyIntake?> getDailyIntake(String userId, String date);
  Future<void> addMealToDailyIntake({
    required String userId,
    required String date,
    required Meal meal,
  });
  Future<void> addWaterToDailyIntake({
    required String userId,
    required String date,
    int amount = 1,
  });
  Stream<DocumentSnapshot<Map<String, dynamic>>> dailyIntakeDocStream(
      String userId, String date);
  Future<void> setDailyIntake(String userId, String date, DailyIntake intake);
}
