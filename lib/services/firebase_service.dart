import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bitewise/data/mock_meals.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:bitewise/models/weight_entry.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create initial user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        // Initialize with default values
        'height': 170.0,
        'weight': 70.0,
        'activityLevel': ActivityLevel.sedentary.toString(),
        'dietaryRestrictions': [],
        'healthGoals': [],
        'dailyCalorieTarget': 2000,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      }
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user data from Firestore
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

  // Save user preferences
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

  Future<void> addMockMeals() async {
    final batch = _firestore.batch();

    for (var mealData in mockMeals) {
      final docRef = _firestore.collection('meals').doc();
      final meal = Meal(
        id: docRef.id,
        name: mealData['name'],
        description: mealData['description'],
        imageUrl: mealData['imageUrl'],
        ingredients: List<String>.from(mealData['ingredients']),
        instructions: List<String>.from(mealData['instructions']),
        calories: mealData['calories'],
        protein: mealData['protein'],
        carbs: mealData['carbs'],
        fat: mealData['fat'],
        mealTypes: List<MealType>.from(mealData['mealTypes']),
        categories: List<MealCategory>.from(mealData['categories']),
        allergens: List<String>.from(mealData['allergens']),
        isUserCreated: mealData['isUserCreated'],
        isPublic: mealData['isPublic'],
        rating: mealData['rating'],
        reviewCount: mealData['reviewCount'],
        createdAt: DateTime.now(),
      );

      batch.set(docRef, meal.toMap());
    }

    await batch.commit();
  }

  Future<List<Meal>> getMeals() async {
    try {
      final snapshot = await _firestore
          .collection('meals')
          .where('isPublic', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Meal.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }

  Future<MealPlan?> getFirstMealPlan() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('mealPlans').limit(1).get();

    if (snapshot.docs.isEmpty) return null;
    return MealPlan.fromDoc(snapshot.docs.first);
  }

  Future<List<Meal>> getMealsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('meals')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return snapshot.docs
        .map((doc) => Meal.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> createBulkMealPlans() async {
    final firestore = FirebaseFirestore.instance;
    final DateTime today = DateTime.now();
    for (int i = 0; i < 4; i++) {
      final DateTime weekStart = today.add(Duration(days: i * 7));
      final mealPlanData = {
        'startDate': Timestamp.fromDate(weekStart),
        'days': [
          {
            'dayOfWeek': 'Monday',
            'meals': [
              {'mealId': 'meal1', 'mealType': 'breakfast'},
              {'mealId': 'meal2', 'mealType': 'lunch'},
              {'mealId': 'meal3', 'mealType': 'dinner'},
            ]
          },
          {
            'dayOfWeek': 'Tuesday',
            'meals': [
              {'mealId': 'meal4', 'mealType': 'breakfast'},
              {'mealId': 'meal5', 'mealType': 'lunch'},
              {'mealId': 'meal6', 'mealType': 'dinner'},
            ]
          },
          // ... add more days as needed ...
        ],
      };
      await firestore.collection('mealPlansMock').add(mealPlanData);
    }
  }

  Future<DocumentSnapshot?> getMealPlanForWeek(DateTime referenceDate) async {
    final user = currentUser;
    if (user == null) return null;
    final snapshot = await _firestore
        .collection('mealPlans')
        .where('userId', isEqualTo: user.uid)
        .where('startDate',
            isLessThanOrEqualTo: Timestamp.fromDate(referenceDate))
        .where('endDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(referenceDate))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    }
    return null;
  }

  // Günlük intake'i getir
  Future<DailyIntake?> getDailyIntake(String userId, String date) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date)
        .get();
    if (doc.exists) {
      return DailyIntake.fromMap(doc.data()!);
    }
    return null;
  }

  // Günlük intake'e meal ekle
  Future<void> addMealToDailyIntake({
    required String userId,
    required String date,
    required Meal meal,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final intake = DailyIntake.fromMap(data);
      // Eğer meal zaten ekli ise tekrar ekleme
      if (intake.mealIds.contains(meal.id)) return;
      final updated = DailyIntake(
        date: date,
        mealIds: [...intake.mealIds, meal.id],
        totalCalories: intake.totalCalories + meal.calories,
        totalProtein: intake.totalProtein + meal.protein,
        totalCarbs: intake.totalCarbs + meal.carbs,
        totalFat: intake.totalFat + meal.fat,
        totalWater: intake.totalWater,
      );
      await docRef.set(updated.toMap());
    } else {
      final newIntake = DailyIntake(
        date: date,
        mealIds: [meal.id],
        totalCalories: meal.calories,
        totalProtein: meal.protein,
        totalCarbs: meal.carbs,
        totalFat: meal.fat,
        totalWater: 0,
      );
      await docRef.set(newIntake.toMap());
    }
  }

  // Günlük intake'e su ekle
  Future<void> addWaterToDailyIntake({
    required String userId,
    required String date,
    int amount = 1,
  }) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      final intake = DailyIntake.fromMap(data);
      final updated = DailyIntake(
        date: date,
        mealIds: intake.mealIds,
        totalCalories: intake.totalCalories,
        totalProtein: intake.totalProtein,
        totalCarbs: intake.totalCarbs,
        totalFat: intake.totalFat,
        totalWater: intake.totalWater + amount,
      );
      await docRef.set(updated.toMap());
    } else {
      final newIntake = DailyIntake(
        date: date,
        mealIds: [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalWater: amount,
      );
      await docRef.set(newIntake.toMap());
    }
  }

  // Günlük intake dokümanını stream olarak getir
  Stream<DocumentSnapshot<Map<String, dynamic>>> dailyIntakeDocStream(
      String userId, String date) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date)
        .snapshots();
  }

  // Günlük intake'i doğrudan set et
  Future<void> setDailyIntake(
      String userId, String date, DailyIntake intake) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(date);
    await docRef.set(intake.toMap());
  }

  /// Kullanıcıya özel mock meal planlar oluşturur
  Future<void> addMockMealPlansForCurrentUser({int weekCount = 4}) async {
    final user = currentUser;
    if (user == null) throw Exception("No user logged in");
    final meals = await getMeals();
    if (meals.length < 3) throw Exception("En az 3 meal olmalı!");
    final mealIds = meals.map((m) => m.id).toList();
    final now = DateTime.now();
    for (int i = 0; i < weekCount; i++) {
      final startDate = now.add(Duration(days: i * 7));
      final endDate = startDate.add(const Duration(days: 6));
      final plan = _generateMockMealPlan(
        userId: user.uid,
        startDate: startDate,
        endDate: endDate,
        mealIds: mealIds,
        name: "Sample Weekly Plan ${i + 1}",
      );
      await _firestore.collection('mealPlans').add(plan);
    }
  }

  /// Yardımcı: Mock meal plan datası oluşturur
  Map<String, dynamic> _generateMockMealPlan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> mealIds,
    required String name,
  }) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final days = List.generate(7, (i) {
      return {
        'dayOfWeek': daysOfWeek[i],
        'meals': [
          {'mealId': mealIds[i % mealIds.length], 'mealType': 'breakfast'},
          {'mealId': mealIds[(i + 1) % mealIds.length], 'mealType': 'lunch'},
          {'mealId': mealIds[(i + 2) % mealIds.length], 'mealType': 'dinner'},
        ]
      };
    });
    return {
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'days': days,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Kullanıcı için günlük kilo kaydı ekle
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

  /// Son X günün kilo geçmişini getir (varsayılan 30 gün)
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
