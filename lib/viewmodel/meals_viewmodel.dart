import 'package:flutter/material.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealsViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  List<Meal> _meals = [];
  MealPlan? _mealPlan;
  bool _isLoading = false;
  String? _error;
  String _currentWeek = 'This Week';

  List<Meal> get meals => _meals;
  MealPlan? get mealPlan => _mealPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentWeek => _currentWeek;

  Future<void> loadMealsAndPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final planData = await _getMealPlanForWeek(DateTime.now());
      if (planData != null) {
        _mealPlan = planData;
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
    try {
      return _meals.firstWhere(
        (meal) => meal.id == id,
        orElse: () {
          print('Warning: Meal with ID $id not found in loaded meals');
          throw Exception('Meal with ID $id not found');
        },
      );
    } catch (e) {
      print('Error getting meal by ID $id: $e');
      return null;
    }
  }

  Future<void> loadMealPlanByWeek(String week) async {
    // If we're already loading or if we're loading the same week's data, don't fetch again
    if (_isLoading || (_mealPlan != null && week == _currentWeek)) return;

    try {
      _isLoading = true;
      _error = null;
      _currentWeek = week;
      notifyListeners();

      final now = DateTime.now();
      final referenceDate =
          week == 'This Week' ? now : now.add(const Duration(days: 7));

      print(
          'Loading meal plan for week: $week (reference date: $referenceDate)');

      // Get meal plan for the selected week
      _mealPlan = await _getMealPlanForWeek(referenceDate);

      // If no meal plan exists, generate a new one
      if (_mealPlan == null) {
        print('No meal plan found, generating new one...');
        await _firebaseService.addMockMealPlansForCurrentUser(weekCount: 1);
        _mealPlan = await _getMealPlanForWeek(referenceDate);
        print('New meal plan generated successfully');
      } else {
        print('Existing meal plan found');
      }

      // Load all meals referenced in the meal plan
      if (_mealPlan != null) {
        final mealIds = _mealPlan!.days
            .expand((day) => day.meals.map((meal) => meal.mealId))
            .toSet()
            .toList();

        print('Loading ${mealIds.length} meals from plan...');
        _meals = await _firebaseService.getMealsByIds(mealIds);
        print('Successfully loaded ${_meals.length} meals');

        // Check if any meals are missing
        if (_meals.length != mealIds.length) {
          final missingMeals = mealIds
              .where((id) => !_meals.any((meal) => meal.id == id))
              .toList();
          print(
              'Warning: ${missingMeals.length} meals could not be loaded. Missing IDs: $missingMeals');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = e.toString();
      print('Error loading meal plan: $e');
      print('Stack trace: $stackTrace');
      notifyListeners();
    }
  }

  Future<MealPlan?> _getMealPlanForWeek(DateTime referenceDate) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('mealPlans')
        .where('userId', isEqualTo: currentUser.uid)
        .where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(referenceDate))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MealPlan.fromDoc(snapshot.docs.first);
  }

  Future<void> addMealToTodayIntake(Meal meal) async {
    try {
      final user = _firebaseService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print('Adding meal ${meal.id} to daily intake for date: $dateStr');
      await _firebaseService.addMealToDailyIntake(
        userId: user.uid,
        date: dateStr,
        meal: meal,
      );
      print('Meal added successfully');
    } catch (e, stackTrace) {
      _error = e.toString();
      print('Error adding meal to daily intake: $e');
      print('Stack trace: $stackTrace');
      notifyListeners();
    }
  }
}
