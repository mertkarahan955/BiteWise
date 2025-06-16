import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/goal.dart';
import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:bitewise/view/auth_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingViewmodel extends ChangeNotifier {
  List<CommonAllergens> dietaryRestrictions = [];
  List<Goal> healthGoals = [];
  double height = 170;
  double weight = 70;
  double targetWeight = 70;
  ActivityLevel activityLevel = ActivityLevel.sedentary;
  int dailyCalorieTarget = 2000;
  Gender gender = Gender.male;
  int age = 25;

  // Search-related properties
  String _searchQuery = '';
  List<CommonAllergens> _searchResults = [];
  bool _isSearching = false;

  int? aiCalorieRecommendation;
  int? aiProteinTarget;
  int? aiFatTarget;
  int? aiCarbTarget;
  bool isFetchingCalorieRecommendation = false;
  String? aiError;

  String get searchQuery => _searchQuery;
  List<CommonAllergens> get searchResults => _searchResults;
  bool get isSearching => _isSearching;

  UserModel get userPreferences => UserModel(
        height: height,
        weight: weight,
        targetWeight: targetWeight,
        activityLevel: activityLevel,
        dietaryRestrictions: dietaryRestrictions,
        healthGoals: healthGoals,
        dailyCalorieTarget: dailyCalorieTarget,
        gender: gender,
        age: age,
      );

  void addDietaryRestrictions(List<CommonAllergens> restrictions) {
    dietaryRestrictions.addAll(restrictions);
    notifyListeners();
  }

  void addHealthGoals(List<Goal> goals) {
    healthGoals.addAll(goals);
    notifyListeners();
  }

  void setHeight(double height) {
    this.height = height;
    notifyListeners();
  }

  void setWeight(double weight) {
    this.weight = weight;
    notifyListeners();
  }

  void setTargetWeight(double targetWeight) {
    this.targetWeight = targetWeight;
    notifyListeners();
  }

  void setActivityLevel(ActivityLevel activityLevel) {
    this.activityLevel = activityLevel;
    notifyListeners();
  }

  void setDailyCalorieTarget(int dailyCalorieTarget) {
    this.dailyCalorieTarget = dailyCalorieTarget;
    notifyListeners();
  }

  void searchAllergens(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
    } else {
      _isSearching = true;
      _searchResults = CommonAllergens.values.where((allergen) {
        final allergenName = _formatAllergenName(allergen);
        return !_isMainAllergen(allergen) &&
            allergenName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  bool _isMainAllergen(CommonAllergens allergen) {
    return [
      CommonAllergens.gluten,
      CommonAllergens.lactose,
      CommonAllergens.soy,
      CommonAllergens.shellfish,
      CommonAllergens.eggs,
      CommonAllergens.nuts,
    ].contains(allergen);
  }

  String _formatAllergenName(CommonAllergens allergen) {
    return allergen
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }

  Future<void> finalizeOnboarding(BuildContext context) async {
    try {
      debugPrint('Starting finalizeOnboarding...');
      final prefs = await SharedPreferences.getInstance();
      debugPrint('Got SharedPreferences instance');

      await prefs.setBool('onboarding_seen', true);
      await prefs.setBool('register_onboarding', true);
      debugPrint('Set onboarding flags in SharedPreferences');

      if (context.mounted) {
        debugPrint('Context is mounted, checking navigation...');
        if (Navigator.canPop(context)) {
          debugPrint('Can pop - returning to previous screen with preferences');
          Navigator.pop(context, userPreferences);
        } else {
          debugPrint('Cannot pop - navigating to signup');
          try {
            debugPrint('Attempting to navigate to auth page with mode: signup');
            debugPrint('User preferences: ${userPreferences.toString()}');

            await Navigator.pushReplacementNamed(
              context,
              Routes.authPageKey,
              arguments: {
                'mode': AuthMode.signup,
                'preferences': userPreferences,
              },
            );
            debugPrint('Navigation completed successfully');
          } catch (navError) {
            debugPrint('Navigation error: $navError');
            rethrow;
          }
        }
      } else {
        debugPrint('Context is not mounted');
      }
    } catch (e) {
      debugPrint('Error in finalizeOnboarding: $e');
      rethrow;
    }
  }

  Future<void> fetchCalorieRecommendation() async {
    isFetchingCalorieRecommendation = true;
    aiError = null;
    notifyListeners();
    try {
      final model =
          FirebaseAI.googleAI().generativeModel(model: 'gemini-2.0-flash');
      final prompt = [
        Content.text(
            '''Based on the user's data, estimate the daily required calories, protein, fat, and carbohydrate. Only answer in this format:
calories: [number]
protein: [number]
fat: [number]
carbohydrate: [number]
Do not add any explanation or anything else.

Data:
Height: ${height.round()} cm
Weight: ${weight.round()} kg
Age: $age
Gender: ${gender.toString().split('.').last}
Activity level: ${activityLevel.toString().split('.').last}
Goals: ${healthGoals.map((g) => g.toString().split('.').last).join(', ')}
'''),
      ];
      final response = await model.generateContent(prompt);
      final text = response.text ?? '';
      final calorieMatch = RegExp(r'calories:\s*(\d+)').firstMatch(text);
      final proteinMatch = RegExp(r'protein:\s*(\d+)').firstMatch(text);
      final fatMatch = RegExp(r'fat:\s*(\d+)').firstMatch(text);
      final carbMatch = RegExp(r'carbohydrate:\s*(\d+)').firstMatch(text);
      aiCalorieRecommendation =
          calorieMatch != null ? int.tryParse(calorieMatch.group(1)!) : null;
      aiProteinTarget =
          proteinMatch != null ? int.tryParse(proteinMatch.group(1)!) : null;
      aiFatTarget = fatMatch != null ? int.tryParse(fatMatch.group(1)!) : null;
      aiCarbTarget =
          carbMatch != null ? int.tryParse(carbMatch.group(1)!) : null;
      if (aiCalorieRecommendation != null) {
        setDailyCalorieTarget(aiCalorieRecommendation!);
      }
      if (aiCalorieRecommendation == null &&
          aiProteinTarget == null &&
          aiFatTarget == null &&
          aiCarbTarget == null) {
        aiError = 'AI response could not be received.';
      }
    } catch (e) {
      aiError = e.toString();
    } finally {
      isFetchingCalorieRecommendation = false;
      notifyListeners();
    }
  }
}
