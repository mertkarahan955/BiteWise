import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<DailyIntake?> get todayIntakeStream {
    final user = _firebaseService.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    final now = DateTime.now();
    final date =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return _firebaseService
        .dailyIntakeDocStream(user.uid, date)
        .map((doc) => doc.exists ? DailyIntake.fromMap(doc.data()!) : null);
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
