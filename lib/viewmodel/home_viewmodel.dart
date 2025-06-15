import 'package:flutter/material.dart';
import 'package:bitewise/models/home_data_model.dart';
import 'package:bitewise/services/home_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeViewmodel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;
  String? _userId;

  HomeData? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;

  Future<void> loadHomeData({required String userId}) async {
    print("loadHomeData");
    _isLoading = true;
    _error = null;
    _userId = userId;
    notifyListeners();
    try {
      _homeData = await _homeService.fetchHomeData(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyIntake() async {
    if (_homeData == null || _userId == null) return;
    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('daily_intake')
        .doc(todayStr)
        .get();
    final data = doc.data() ?? {};
    _homeData = HomeData(
      userName: _homeData!.userName,
      profileImageUrl: _homeData!.profileImageUrl,
      dailyCalories: (data['totalCalories'] ?? 0).toInt(),
      calorieGoal: _homeData!.calorieGoal,
      waterDrank: (data['totalWater'] ?? 0).toInt(),
      waterGoal: _homeData!.waterGoal,
      weeklyProgress: _homeData!.weeklyProgress,
      mealOfTheDay: _homeData!.mealOfTheDay,
      weatherBanner: _homeData!.weatherBanner,
      mealsEatenToday: (data['meals'] ?? []).length,
    );
    notifyListeners();
  }
}
