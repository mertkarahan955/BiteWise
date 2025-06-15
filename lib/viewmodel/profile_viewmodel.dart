import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;
  double? get targetWeight => _user?.weight;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WeightEntry> _weightHistory = [];
  List<WeightEntry> get weightHistory => _weightHistory;

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

  Future<void> loadTodayWeight() async {
    final user = _firebaseService.currentUser;
    if (user == null) return;
    final today = _getTodayString();
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('weight_history')
        .doc(today)
        .get();
    if (doc.exists) {
      _currentWeight =
          (doc.data()?['weight'] ?? _user?.weight ?? 0.0).toDouble();
    } else {
      _currentWeight = _user?.weight;
    }
    notifyListeners();
  }

  Future<void> updateTodayWeight(double newWeight) async {
    final now = DateTime.now();
    await _firebaseService.addWeightEntry(newWeight, now);
    _currentWeight = newWeight;
    notifyListeners();
  }

  Future<void> loadWeightHistory() async {
    try {
      _weightHistory = await _firebaseService.getWeightHistory(days: 30);
      notifyListeners();
    } catch (e) {
      // ignore error for now
    }
  }

  Future<void> updateWaterIntake(int newWaterIntake) async {
    // Prevent negative water intake
    if (newWaterIntake < 0) return;

    final user = _firebaseService.currentUser;
    if (user == null) return;

    final today = _getTodayString();
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('daily_intake')
        .doc(today)
        .get();

    if (doc.exists) {
      await doc.reference.update({'totalWater': newWaterIntake});
    } else {
      await doc.reference.set({
        'date': today,
        'totalWater': newWaterIntake,
        'totalCalories': 0,
        'totalProtein': 0,
        'totalCarbs': 0,
        'totalFat': 0,
        'mealIds': [],
      });
    }
  }

  @override
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
        await loadTodayWeight();
        await loadWeightHistory();
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
