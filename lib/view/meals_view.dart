import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/models/meal_model.dart';
import 'package:bitewise/view/meal_details_view.dart';
import 'package:bitewise/view/components/meal_card.dart';
import 'package:bitewise/view/components/popup_notification.dart';

class MealsView extends StatefulWidget {
  const MealsView({super.key});

  @override
  State<MealsView> createState() => _MealsViewState();
}

class _MealsViewState extends State<MealsView> {
  String selectedWeek = 'This Week';

  @override
  void initState() {
    super.initState();
    // Load initial meal plan
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'My Meal Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
  const MealPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MealsViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${viewModel.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.loadMealPlanByWeek('This Week');
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final mealPlan = viewModel.mealPlan;
        if (mealPlan == null) {
          // Show popup notification
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final overlay = Overlay.of(context);
            late final OverlayEntry overlayEntry;
            overlayEntry = OverlayEntry(
              builder: (context) => PopupNotification(
                message: 'Your personalized meal plan is being generated...',
                type: PopupNotificationType.info,
                duration: const Duration(seconds: 3),
                onClose: () {
                  overlayEntry.remove();
                  // Start generating meal plan
                  viewModel.loadMealPlanByWeek('This Week');
                },
              ),
            );
            overlay.insert(overlayEntry);
          });

          return const Center(
            child: Text(
              'Generating your meal plan...',
              style: TextStyle(fontSize: 18),
            ),
          );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      day.dayOfWeek,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: day.meals.map((entry) {
                        final meal = viewModel.getMealById(entry.mealId);
                        if (meal == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: MealCard(
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
        );
      },
    );
  }
}
