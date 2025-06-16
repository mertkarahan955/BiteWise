import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IProfileService {
  User? get currentUser;
  Future<Map<String, dynamic>?> getUserData(String userId);
  Future<void> saveUserPreferences({
    required String userId,
    required UserModel userModel,
  });
  Future<void> addWeightEntry(double weight, DateTime date);
  Future<List<WeightEntry>> getWeightHistory({int days = 30});
}
