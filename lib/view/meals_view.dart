import 'package:bitewise/assets/meal_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/models/meal_model.dart';

class MealsView extends StatelessWidget {
  const MealsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MealsViewmodel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          final mealPlan = viewModel.mealPlan;
          if (mealPlan == null) {
            return const Center(child: Text('No meal plan found'));
          }

          return Column(
            children: [
              // Header controls
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Week dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: 'This Week',
                            items: [
                              DropdownMenuItem(
                                  value: 'This Week', child: Text('This Week')),
                              DropdownMenuItem(
                                  value: 'Next Week', child: Text('Next Week')),
                            ],
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Meal type dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: 'All Meals',
                            items: [
                              DropdownMenuItem(
                                  value: 'All Meals', child: Text('All Meals')),
                              DropdownMenuItem(
                                  value: 'Breakfast', child: Text('Breakfast')),
                              DropdownMenuItem(
                                  value: 'Lunch', child: Text('Lunch')),
                              DropdownMenuItem(
                                  value: 'Dinner', child: Text('Dinner')),
                            ],
                            onChanged: (value) {},
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Profile icon
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child:
                              Icon(Icons.person, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Add Meal button
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Add Meal',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Spacer(),
                        // My Meal Plan title
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'My Meal\nPlan',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Meals list
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: mealPlan.days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, dayIndex) {
                    final day = mealPlan.days[dayIndex];
                    return Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day.dayOfWeek,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              children: day.meals.map((entry) {
                                final meal =
                                    viewModel.getMealById(entry.mealId);
                                if (meal == null)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _MealCard(
                                    meal: meal,
                                    mealType: entry.mealType,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal;
  final String mealType;

  const _MealCard({required this.meal, required this.mealType});

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

  Color getMealTypeColor(String type) {
    switch (type) {
      case 'breakfast':
        return Colors.orange.shade100;
      case 'lunch':
        return Colors.green.shade100;
      case 'dinner':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = mealSvgAssets[meal.id];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Meal image fills the card
          SizedBox(
            width: double.infinity,
            height: 180,
            child: assetPath != null
                ? SvgPicture.asset(assetPath, fit: BoxFit.cover)
                : (meal.imageUrl.isNotEmpty
                    ? Image.network(meal.imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant,
                            size: 48, color: Colors.grey),
                      )),
          ),
          // Chips overlay
          Positioned(
            top: 12,
            left: 12,
            child: Chip(
              label: Text(
                getMealTypeLabel(mealType),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Chip(
              label: Text(
                // If you have protein, use: '${meal.protein}g protein', else use calories
                '${meal.calories.round()} kcal',
                style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              backgroundColor: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          ),
        ],
      ),
    );
  }
}
