import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageTransformers {
  ImageTransformers(this.path, {this.width, this.height});

  final String path;
  final double? width;
  final double? height;

  // For SVG images in the root assets folder
  SvgPicture get svg => SvgPicture.asset(
        'assets/$path.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
      );

  // For SVG images in the logo subfolder
  SvgPicture get svgLogo => SvgPicture.asset(
        'assets/logo/$path.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
      );

  // For SVG icons in the icons subfolder
  SvgPicture get icon => SvgPicture.asset(
        'assets/icons/$path.svg',
        width: width,
        height: height,
        fit: BoxFit.contain,
      );

  // For PNG images
  Image get image => Image.asset(
        'assets/$path.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
      );
}

class ImageConstants {
  // Logo
  static final String logo = 'bitewise_logo';

  // Icons
  static final String passwordHintEye = 'eye_hidden';
  static final String restaurantGuideIcon = 'restaurant_guide';
  static final String dietetaryPreferencesIcon = "dietetary_preferences";
  static final String alertRemindersIcon = "alert_reminders";
  static final String socialIcon = "social";
  static final String glutenIcon = "gluten";
  static final String lactoseIcon = "lactose";
  static final String veganIcon = "vegan";
  static final String fishIcon = "shellfish";
  static final String eggIcon = "egg";
  static final String searchicon = "search";
  static final String loseWeightIcon = "lose_weight";
  static final String gainMuscleIcon = "gain_muscle";
  static final String maintainWellnessIcon = "heart";
  static final String betterNutritionIcon = "apple";
  static final String recipeIcon = "recipe";
  // Onboarding
  static final Map<int, String> onboarding = {
    1: 'onboarding_1',
    2: 'onboarding_2',
    3: 'onboarding_3'
  };
}
