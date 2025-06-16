import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/models/meal_plan_model.dart';
import 'package:bitewise/data/mock_meals.dart';
import 'package:bitewise/services/interfaces/i_meal_service.dart';

class MealService implements IMealService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
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

  @override
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

  @override
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

  @override
  Future<MealPlan?> getMealPlanForWeek(DateTime referenceDate) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('mealPlans')
        .where('userId', isEqualTo: currentUser.uid)
        .where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(referenceDate))
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return MealPlan.fromDoc(snapshot.docs.first);
  }

  @override
  Future<void> addMockMealPlansForCurrentUser({int weekCount = 4}) async {
    final user = currentUser;
    if (user == null) throw Exception("No user logged in");
    final meals = await getMeals();
    if (meals.length < 3) throw Exception("At least 3 meals required!");
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
        name: "Sample Weekly Plan ${i + 1}",
      );
      await _firestore.collection('mealPlans').add(plan);
    }
  }

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
}
