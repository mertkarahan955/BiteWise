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
  ActivityLevel activityLevel = ActivityLevel.sedentary;
  int dailyCalorieTarget = 2000;

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
        activityLevel: activityLevel,
        dietaryRestrictions: dietaryRestrictions,
        healthGoals: healthGoals,
        dailyCalorieTarget: dailyCalorieTarget,
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (Navigator.canPop(context)) {
      Navigator.pop(context, userPreferences);
    } else {
      Navigator.pushReplacementNamed(
        context,
        Routes.authPageKey,
        arguments: {
          'mode': AuthMode.signup,
          'preferences': userPreferences,
        },
      );
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
            '''Kullanıcıdan alınan verilere göre günlük alınması gereken kalori, protein, yağ ve karbonhidrat miktarını tahmin et. Sadece şu formatta cevap ver:\nkalori: [sayı]\nprotein: [sayı]\nyağ: [sayı]\nkarbonhidrat: [sayı]\nAçıklama veya başka bir şey ekleme.\n\nVeriler:\nBoy: ${height.round()} cm\nKilo: ${weight.round()} kg\nAktivite seviyesi: ${activityLevel.toString().split('.').last}\nHedefler: ${healthGoals.map((g) => g.toString().split('.').last).join(', ')}\n'''),
      ];
      final response = await model.generateContent(prompt);
      final text = response.text ?? '';
      final calorieMatch = RegExp(r'kalori:\s*(\d+)').firstMatch(text);
      final proteinMatch = RegExp(r'protein:\s*(\d+)').firstMatch(text);
      final fatMatch = RegExp(r'yağ:\s*(\d+)').firstMatch(text);
      final carbMatch = RegExp(r'karbonhidrat:\s*(\d+)').firstMatch(text);
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
        aiError = 'AI yanıtı alınamadı.';
      }
    } catch (e) {
      aiError = e.toString();
    } finally {
      isFetchingCalorieRecommendation = false;
      notifyListeners();
    }
  }
}
