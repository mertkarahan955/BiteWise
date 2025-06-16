import 'package:bitewise/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:bitewise/services/profile_service.dart';
import 'package:bitewise/services/meal_service.dart';
import 'package:bitewise/services/nutrition_service.dart';
import 'package:bitewise/services/home_service.dart';
import 'package:bitewise/services/interfaces/i_firebase_service.dart';
import 'package:bitewise/services/interfaces/i_profile_service.dart';
import 'package:bitewise/services/interfaces/i_meal_service.dart';
import 'package:bitewise/services/interfaces/i_nutrition_service.dart';
import 'package:bitewise/services/interfaces/i_home_service.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/viewmodel/home_viewmodel.dart';
import 'package:bitewise/viewmodel/splash_viewmodel.dart';
import 'package:bitewise/view/auth_view.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton<IFirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<IProfileService>(() => ProfileService());
  locator.registerLazySingleton<IMealService>(() => MealService());
  locator.registerLazySingleton<INutritionService>(() => NutritionService());
  locator.registerLazySingleton<IHomeService>(() => HomeService());
  locator.registerLazySingleton<AuthService>(() => AuthService());

  // Viewmodels
  locator.registerFactory<AuthViewmodel>(() => AuthViewmodel(
        initialMode: AuthMode.login,
        firebaseService: locator<IFirebaseService>(),
        profileService: locator<IProfileService>(),
      ));

  locator.registerFactory<ProfileViewmodel>(() => ProfileViewmodel(
        profileService: locator<IProfileService>(),
        auth: locator<AuthService>(),
        firestore: FirebaseFirestore.instance,
      ));

  locator.registerFactory<MealsViewmodel>(() => MealsViewmodel(
        mealService: locator<IMealService>(),
        nutritionService: locator<INutritionService>(),
      ));

  locator.registerFactory<HomeViewmodel>(() => HomeViewmodel(
        homeService: locator<IHomeService>(),
        nutritionService: locator<INutritionService>(),
      ));

  locator.registerFactory<SplashViewmodel>(() => SplashViewmodel(
        firebaseService: locator<IFirebaseService>(),
      ));
}
