import 'package:bitewise/models/home_data_model.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:bitewise/models/meal_model.dart';

class HomeService {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<HomeData> fetchHomeData(String userId) async {
    print("fetchHomeData");
    // 1. User info
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};
    final userName = userData['name'] ?? '';
    final profileImageUrl =
        userData['profileImageUrl'] ?? userData['photoUrl'] ?? '';
    final calorieGoal = userData['dailyCalorieTarget'] ?? 2000;
    final waterGoal = 5; // Fixed or can be taken from userData

    // 2. Today's intake
    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final dailyIntakeDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('daily_intake')
        .doc(todayStr)
        .get();
    final dailyIntake = dailyIntakeDoc.data() ?? {};
    final dailyCalories = (dailyIntake['totalCalories'] ?? 0).toInt();
    final waterDrank = (dailyIntake['totalWater'] ?? 0).toInt();
    final mealsEatenToday = (dailyIntake['meals'] ?? []).length;

    // 3. Weekly progress
    List<int> weeklyProgress = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_intake')
          .doc(dateStr)
          .get();
      final data = doc.data() ?? {};
      weeklyProgress.add((data['totalCalories'] ?? 0).toInt());
    }

    // 4. Meal of the day (random public meal)
    final mealsQuery = await _firestore
        .collection('meals')
        .where('isPublic', isEqualTo: true)
        .limit(20)
        .get();
    final meals = mealsQuery.docs;
    final random = Random();
    final mealDoc =
        meals.isNotEmpty ? meals[random.nextInt(meals.length)] : null;
    final mealOfTheDay = mealDoc != null
        ? MealOfTheDay(
            id: mealDoc.id,
            name: mealDoc['name'] ?? '',
            imageUrl: mealDoc['imageUrl'] ?? '',
            description: mealDoc['description'] ?? '',
            ingredients: List<String>.from(mealDoc['ingredients'] ?? []),
            instructions: List<String>.from(mealDoc['instructions'] ?? []),
            calories: (mealDoc['calories'] ?? 0.0).toDouble(),
            protein: (mealDoc['protein'] ?? 0.0).toDouble(),
            carbs: (mealDoc['carbs'] ?? 0.0).toDouble(),
            fat: (mealDoc['fat'] ?? 0.0).toDouble(),
            mealTypes: (mealDoc['mealTypes'] as List<dynamic>?)
                    ?.map((e) => MealType.values.firstWhere(
                        (type) => type.toString() == e,
                        orElse: () => MealType.breakfast))
                    .toList() ??
                [],
            categories: (mealDoc['categories'] as List<dynamic>?)
                    ?.map((e) => MealCategory.values.firstWhere(
                        (cat) => cat.toString() == e,
                        orElse: () => MealCategory.american))
                    .toList() ??
                [],
            allergens: List<String>.from(mealDoc['allergens'] ?? []),
            isUserCreated: mealDoc['isUserCreated'] ?? false,
            createdBy: mealDoc['createdBy'],
            createdAt: mealDoc['createdAt'] is DateTime
                ? mealDoc['createdAt']
                : DateTime.now(),
            updatedAt: mealDoc['updatedAt'],
            rating: mealDoc['rating']?.toDouble(),
            reviewCount: mealDoc['reviewCount'],
            isPublic: mealDoc['isPublic'] ?? true,
          )
        : MealOfTheDay(id: '', name: 'No Meal', imageUrl: '');

    // 5. Weather suggestion (mock)
    final weatherBanner = WeatherBanner(
      weatherType: 'rainy',
      suggestionText: '🌧️ Rainy day? Try our warming lentil soup recipe!',
      suggestedMealId: mealOfTheDay.id.isNotEmpty ? mealOfTheDay.id : null,
    );

    return HomeData(
      userName: userName,
      profileImageUrl: profileImageUrl,
      dailyCalories: dailyCalories,
      calorieGoal: calorieGoal,
      waterDrank: waterDrank,
      waterGoal: waterGoal,
      weeklyProgress: weeklyProgress,
      mealOfTheDay: mealOfTheDay,
      weatherBanner: weatherBanner,
      mealsEatenToday: mealsEatenToday,
    );
  }
}
