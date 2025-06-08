import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:bitewise/services/firebase_service.dart';

class MealsViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Meal> _meals = [];
  MealPlan? _mealPlan;
  bool _isLoading = false;
  String? _error;

  List<Meal> get meals => _meals;
  MealPlan? get mealPlan => _mealPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMealsAndPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final planData =
          await _firebaseService.getMealPlanForWeek(DateTime.now());
      if (planData != null) {
        _mealPlan = MealPlan.fromDoc(planData);
        // Collect all mealIds from the plan
        final mealIds = _mealPlan!.days
            .expand((d) => d.meals)
            .map((e) => e.mealId)
            .toSet()
            .toList();
        // Fetch all meals by IDs
        _meals = await _firebaseService.getMealsByIds(mealIds);
      } else {
        _mealPlan = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Meal? getMealById(String id) {
    return _meals.firstWhere((m) => m.id == id);
  }

  Future<void> loadMealPlanByWeek(String selectedWeek) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      DateTime referenceDate;
      if (selectedWeek == 'This Week') {
        referenceDate = DateTime.now();
      } else {
        final now = DateTime.now();
        referenceDate = now.add(Duration(days: 8 - now.weekday)); // next Monday
      }

      final planData = await _firebaseService.getMealPlanForWeek(referenceDate);
      if (planData != null) {
        _mealPlan = MealPlan.fromDoc(planData);

        final mealIds = _mealPlan!.days
            .expand((d) => d.meals)
            .map((e) => e.mealId)
            .toSet()
            .toList();

        _meals = await _firebaseService.getMealsByIds(mealIds);
      } else {
        _mealPlan = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMealToTodayIntake(Meal meal) async {
    final user = _firebaseService.currentUser;
    if (user == null) return;
    final now = DateTime.now();
    final date =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await _firebaseService.addMealToDailyIntake(
      userId: user.uid,
      date: date,
      meal: meal,
    );
  }
}
