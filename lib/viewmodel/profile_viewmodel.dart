import 'package:bitewise/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitewise/services/interfaces/i_profile_service.dart';
import 'package:bitewise/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class ProfileViewmodel extends ChangeNotifier {
  final IProfileService _profileService;
  final AuthService _auth;
  final FirebaseFirestore _firestore;
  UserModel? _userData;
  bool _isLoading = false;
  String? _error;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;
  double? get targetWeight => _userData?.weight;

  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WeightEntry> _weightHistory = [];
  List<WeightEntry> get weightHistory => _weightHistory;

  Stream<dynamic>? _todayIntakeStream;
  Stream<dynamic>? get todayIntakeStream => _todayIntakeStream;

  ProfileViewmodel({
    required IProfileService profileService,
    required AuthService auth,
    required FirebaseFirestore firestore,
  })  : _profileService = profileService,
        _auth = auth,
        _firestore = firestore {
    _initializeTodayIntakeStream();
  }

  void _initializeTodayIntakeStream() {
    final user = _auth.currentUser;
    if (user != null) {
      final today = _getTodayString();
      _todayIntakeStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_intake')
          .doc(today)
          .snapshots();
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> loadTodayWeight() async {
    final user = _profileService.currentUser;
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
          (doc.data()?['weight'] ?? _userData?.weight ?? 0.0).toDouble();
    } else {
      _currentWeight = _userData?.weight;
    }
    notifyListeners();
  }

  Future<void> updateTodayWeight(double weight) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final today = DateTime.now();
      final dateStr =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Update weight in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'weight': weight,
      });

      // Add weight entry to history
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('weight_history')
          .doc(dateStr)
          .set({
        'weight': weight,
        'date': dateStr,
      });

      await loadUserData();
      await loadWeightHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTargetWeight(double weight) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Update target weight in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'targetWeight': weight,
      });

      await loadUserData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _profileService.currentUser?.uid;
      if (userId != null) {
        final userData = await _profileService.getUserData(userId);
        if (userData != null) {
          _userData = UserModel.fromJson(userData);
          await loadTodayWeight();
          await loadWeightHistory();
          _initializeTodayIntakeStream();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeightHistory() async {
    try {
      _weightHistory = await _profileService.getWeightHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading weight history: $e');
    }
  }

  Future<void> updateUserPreferences(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _profileService.currentUser?.uid;
      if (userId != null) {
        await _profileService.saveUserPreferences(
          userId: userId,
          userModel: updatedUser,
        );
        _userData = updatedUser;
      }
    } catch (e) {
      debugPrint('Error updating user preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWeightEntry(double weight) async {
    try {
      await _profileService.addWeightEntry(weight, DateTime.now());
      await loadWeightHistory();
    } catch (e) {
      debugPrint('Error adding weight entry: $e');
    }
  }

  Future<void> updateWaterIntake(int newWaterIntake) async {
    // Prevent negative water intake
    if (newWaterIntake < 0) return;

    final user = _profileService.currentUser;
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
}
