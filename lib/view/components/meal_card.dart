import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/view/meal_details_view.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/assets/meal_images.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final String mealType;

  const MealCard({super.key, required this.meal, required this.mealType});

  String getMealTypeLabel(String type) {
    switch (type) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return 'Meal';
    }
  }

  String getMealImage() {
    // Get a random image from the available assets if meal ID is not in mapping
    final assets = mealSvgAssets.values.toList();
    return mealSvgAssets[meal.id] ??
        assets[DateTime.now().millisecondsSinceEpoch % assets.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailsView(meal: meal),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 180,
              child: SvgPicture.asset(
                getMealImage(),
                fit: BoxFit.cover,
                placeholderBuilder: (context) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.restaurant,
                      size: 48, color: Colors.grey),
                ),
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading SVG for meal ${meal.id}: $error');
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant,
                        size: 48, color: Colors.grey),
                  );
                },
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Chip(
                label: Text(
                  getMealTypeLabel(mealType),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(
                      '${meal.calories.round()} kcal',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.orange.shade50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                  const SizedBox(width: 4),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await context
                            .read<MealsViewmodel>()
                            .addMealToTodayIntake(meal);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Meal added to today!')),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.add,
                            size: 20, color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
