import 'package:bitewise/models/daily_intake.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/services/interfaces/i_nutrition_service.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/home_data_model.dart';
import 'package:bitewise/services/interfaces/i_home_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeViewmodel extends ChangeNotifier {
  final IHomeService _homeService;
  final INutritionService _nutritionService;

  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;
  String? _userId;
  DailyIntake? _dailyIntake;
  bool _isInitialized = false;

  HomeViewmodel({
    required INutritionService nutritionService,
    required IHomeService homeService,
  })  : _nutritionService = nutritionService,
        _homeService = homeService;

  HomeData? get homeData => _homeData;
  bool get isLoading => _isLoading && !_isInitialized;
  String? get userId => _userId;
  String? get error => _error;
  DailyIntake? get dailyIntake => _dailyIntake;
  bool get isInitialized => _isInitialized;

  Future<void> loadHomeData({required String userId}) async {
    if (_isLoading) return;

    try {
      _userId = userId;
      _isLoading = true;
      _error = null;
      _isInitialized = false;
      notifyListeners();

      final data = await _homeService.fetchHomeData(userId);
      _homeData = data;
      _isInitialized = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDailyIntakeInternal() async {
    try {
      final userId = _nutritionService.currentUser?.uid;
      if (userId != null) {
        final today = DateTime.now().toString().split(' ')[0];
        final intake = await _nutritionService.getDailyIntake(userId, today);
        if (!_isLoading) return;
        _dailyIntake = intake;
        notifyListeners();
      }
    } catch (e) {
      if (!_isLoading) return;
      debugPrint('Error loading daily intake: $e');
    }
  }

  Future<void> loadDailyIntake() async {
    if (_userId == null || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _homeService.fetchHomeData(_userId!);
      _homeData = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMealToDailyIntake(Meal meal) async {
    try {
      final userId = _nutritionService.currentUser?.uid;
      if (userId != null) {
        final today = DateTime.now().toString().split(' ')[0];
        await _nutritionService.addMealToDailyIntake(
          userId: userId,
          date: today,
          meal: meal,
        );
        await _loadDailyIntakeInternal();
      }
    } catch (e) {
      debugPrint('Error adding meal to daily intake: $e');
    }
  }

  Future<void> addWaterToDailyIntake(int amount) async {
    try {
      final userId = _nutritionService.currentUser?.uid;
      if (userId != null) {
        final today = DateTime.now().toString().split(' ')[0];
        await _nutritionService.addWaterToDailyIntake(
          userId: userId,
          date: today,
          amount: amount,
        );
        await _loadDailyIntakeInternal();
      }
    } catch (e) {
      debugPrint('Error adding water to daily intake: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> get dailyIntakeStream {
    final userId = _nutritionService.currentUser?.uid;
    if (userId != null) {
      final today = DateTime.now().toString().split(' ')[0];
      return _nutritionService.dailyIntakeDocStream(userId, today);
    }
    return Stream.empty();
  }

  @override
  void dispose() {
    _isLoading = false;
    super.dispose();
  }
}
