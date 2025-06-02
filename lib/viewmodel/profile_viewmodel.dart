import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/material.dart';

class ProfileViewmodel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
