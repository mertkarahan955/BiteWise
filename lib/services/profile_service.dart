import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:bitewise/services/interfaces/i_profile_service.dart';

class ProfileService implements IProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  @override
  Future<void> saveUserPreferences({
    required String userId,
    required UserModel userModel,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'height': userModel.height,
        'weight': userModel.weight,
        'activityLevel': userModel.activityLevel.toString(),
        'dietaryRestrictions':
            userModel.dietaryRestrictions.map((e) => e.toString()).toList(),
        'healthGoals': userModel.healthGoals.map((e) => e.toString()).toList(),
        'dailyCalorieTarget': userModel.dailyCalorieTarget,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  Future<void> addWeightEntry(double weight, DateTime date) async {
    final user = currentUser;
    if (user == null) throw Exception("No user logged in");
    final roundedWeight = double.parse(weight.toStringAsFixed(1));
    final dateStr =
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weight_history')
        .doc(dateStr)
        .set({'date': dateStr, 'weight': roundedWeight});
    // Update user's current weight as well
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'weight': roundedWeight});
  }

  @override
  Future<List<WeightEntry>> getWeightHistory({int days = 30}) async {
    final user = currentUser;
    if (user == null) throw Exception("No user logged in");
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    final startStr =
        "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('weight_history')
        .where('date', isGreaterThanOrEqualTo: startStr)
        .orderBy('date')
        .get();
    return snapshot.docs.map((doc) => WeightEntry.fromMap(doc.data())).toList();
  }
}
