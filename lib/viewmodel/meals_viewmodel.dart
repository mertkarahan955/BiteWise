import 'package:flutter/material.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:bitewise/services/interfaces/i_meal_service.dart';
import 'package:bitewise/services/interfaces/i_nutrition_service.dart';
import 'package:flutter/foundation.dart';

class MealsViewmodel extends ChangeNotifier {
  final IMealService _mealService;
  final INutritionService _nutritionService;

  List<Meal> _meals = [];
  MealPlan? _mealPlan;
  bool _isLoading = false;
  String? _error;
  String _currentWeek = 'This Week';
  bool _isInitialized = false;

  MealsViewmodel({
    required IMealService mealService,
    required INutritionService nutritionService,
  })  : _mealService = mealService,
        _nutritionService = nutritionService;

  List<Meal> get meals => _meals;
  MealPlan? get mealPlan => _mealPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentWeek => _currentWeek;
  bool get isInitialized => _isInitialized;

  Future<void> loadMeals() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meals = await _mealService.getMeals();
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMealPlans() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _mealPlan = await _mealService.getMealPlanForWeek(DateTime.now());
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading meal plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMockMeals() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _mealService.addMockMeals();
      await loadMeals();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding mock meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMockMealPlans() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _mealService.addMockMealPlansForCurrentUser();
      await loadMealPlans();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding mock meal plans: $e');
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
    if (_isLoading || (_mealPlan != null && week == _currentWeek)) {
      print('Skipping meal plan load - Already loading or same week');
      return;
    }

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
      final mealPlan = await _mealService.getMealPlanForWeek(referenceDate);
      print(
          'Meal plan fetch result: ${mealPlan != null ? 'Found' : 'Not found'}');

      // If no meal plan exists, generate a new one
      if (mealPlan == null) {
        print('No meal plan found, generating new one...');
        await _mealService.addMockMealPlansForCurrentUser(weekCount: 1);
        _mealPlan = await _mealService.getMealPlanForWeek(referenceDate);
        print(
            'New meal plan generated: ${_mealPlan != null ? 'Success' : 'Failed'}');
      } else {
        print('Existing meal plan found, setting to state');
        _mealPlan = mealPlan;
      }

      // Load all meals referenced in the meal plan
      if (_mealPlan != null) {
        final mealIds = _mealPlan!.days
            .expand((day) => day.meals.map((meal) => meal.mealId))
            .toSet()
            .toList();

        print('Loading ${mealIds.length} meals from plan...');
        _meals = await _mealService.getMealsByIds(mealIds);
        print('Successfully loaded ${_meals.length} meals');

        // Check if any meals are missing
        if (_meals.length != mealIds.length) {
          final missingMeals = mealIds
              .where((id) => !_meals.any((meal) => meal.id == id))
              .toList();
          print(
              'Warning: ${missingMeals.length} meals could not be loaded. Missing IDs: $missingMeals');
        }
      } else {
        print('Warning: No meal plan available after loading/generation');
      }

      _isInitialized = true;
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

  Future<void> addMealToTodayIntake(Meal meal) async {
    try {
      final user = _mealService.currentUser;
      if (user == null) throw Exception('No user logged in');

      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      print('Adding meal ${meal.id} to daily intake for date: $dateStr');
      await _nutritionService.addMealToDailyIntake(
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
