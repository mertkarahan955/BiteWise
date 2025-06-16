import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IMealService {
  User? get currentUser;
  Future<List<Meal>> getMeals();
  Future<List<Meal>> getMealsByIds(List<String> ids);
  Future<void> addMockMeals();
  Future<MealPlan?> getMealPlanForWeek(DateTime referenceDate);
  Future<void> addMockMealPlansForCurrentUser({int weekCount = 4});
}
