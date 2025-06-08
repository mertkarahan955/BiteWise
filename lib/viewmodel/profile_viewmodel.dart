import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/daily_intake.dart';

class ProfileViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Stream<DailyIntake?> get todayIntakeStream {
    final user = _firebaseService.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    final today = _getTodayString();
    final docStream = _firebaseService.dailyIntakeDocStream(user.uid, today);
    return docStream.asyncMap((doc) async {
      if (doc.exists) {
        final intake = DailyIntake.fromMap(doc.data()!);
        if (intake.date == today) {
          return intake;
        }
      }
      final newIntake = DailyIntake(
        date: today,
        mealIds: [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalWater: 0,
      );
      await _firebaseService.setDailyIntake(user.uid, today, newIntake);
      return newIntake;
    });
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Get user data from Firestore
      final userData = await _firebaseService.getUserData(currentUser.uid);
      if (userData != null) {
        _user = UserModel.fromJson(userData);
      } else {
        _error = 'User data not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
