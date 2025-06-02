import 'package:bitewise/assets/meal_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/models/meal_model.dart';

class MealsView extends StatefulWidget {
  const MealsView({super.key});

  @override
  State<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends State<MealsView> {
  String selectedWeek = 'This Week';
  MealType? selectedMealType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealsViewmodel>().loadMealPlanByWeek(selectedWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // 🔽 Week dropdown (fully functional)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedWeek,
                        items: const [
                          DropdownMenuItem(
                              value: 'This Week', child: Text('This Week')),
                          DropdownMenuItem(
                              value: 'Next Week', child: Text('Next Week')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedWeek = value;
                            });
                            context
                                .read<MealsViewmodel>()
                                .loadMealPlanByWeek(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Meal type dropdown (pasif)

                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(Icons.person, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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
                          side: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Spacer(),
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
          // Only this widget will rebuild when meal plan changes
          Expanded(child: MealPlans()),
        ],
      ),
    );
  }
}

class MealPlans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MealsViewmodel>(
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
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: day.meals.map((entry) {
                        final meal = viewModel.getMealById(entry.mealId);
                        if (meal == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child:
                              _MealCard(meal: meal, mealType: entry.mealType),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final assetPath = mealSvgAssets[meal.id];
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
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
                '${meal.calories.round()} kcal',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
