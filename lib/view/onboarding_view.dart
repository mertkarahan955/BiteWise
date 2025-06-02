import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/goal.dart';
import 'package:bitewise/view/auth_view.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:bitewise/viewmodel/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/utils/image.dart';
import 'package:provider/provider.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width * 0.2,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ImageTransformers(ImageConstants.logo).svgLogo,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Show confirmation dialog before going to login
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Skip Onboarding?'),
                  content: const Text(
                    'You can skip onboarding and go directly to login. However, you\'ll need to complete onboarding before registering.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                          context,
                          Routes.authPageKey,
                          arguments: AuthMode.login,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Go to Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const OnboardingPageView(),
    );
  }
}

class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingPage> _buildPages(OnboardingViewmodel viewModel) {
    return [
      // First page - Read only
      OnboardingPage(
        title: "Welcome to BiteWise!",
        subtitle: "Let's help you get started with a personalized experience",
        body: GridView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          children: [
            _buildSectionTitle(
              viewModel,
              ImageConstants.restaurantGuideIcon,
              "Restaurant Guide",
              "Find safe dining options",
              isPressable: false,
            ),
            _buildSectionTitle(
              viewModel,
              ImageConstants.dietetaryPreferencesIcon,
              "Dietary Preferences",
              "Set your restrictions",
              isPressable: false,
            ),
            _buildSectionTitle(
              viewModel,
              ImageConstants.alertRemindersIcon,
              "Alerts & Reminders",
              "Stay informed",
              isPressable: false,
            ),
            _buildSectionTitle(
              viewModel,
              ImageConstants.socialIcon,
              "Social Features",
              "Connect with others",
              isPressable: false,
            ),
          ],
        ),
      ),
      // Second page - Dietary Restrictions
      OnboardingPage(
        title: "Let's Personalize Your Experience",
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              children: [
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.glutenIcon,
                  "Gluten",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.gluten),
                ),
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.lactoseIcon,
                  "Lactose",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.lactose),
                ),
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.veganIcon,
                  "Vegan",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.soy),
                ),
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.fishIcon,
                  "Shellfish",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.shellfish),
                ),
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.eggIcon,
                  "Eggs",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.eggs),
                ),
                _buildSectionTitle(
                  viewModel,
                  ImageConstants.veganIcon,
                  "Nuts",
                  "",
                  isPressable: true,
                  isSelected: viewModel.dietaryRestrictions
                      .contains(CommonAllergens.nuts),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Additional Dietary Restrictions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelStyle: const TextStyle(fontSize: 12),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 6, minHeight: 6),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ImageTransformers(ImageConstants.searchicon).icon,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                labelText: 'Search other dietary restrictions',
              ),
              onChanged: (value) => viewModel.searchAllergens(value),
            ),
            if (viewModel.isSearching &&
                viewModel.searchResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Search Results",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: viewModel.searchResults.map((allergen) {
                  return ChoiceChip(
                    label: Text(_formatAllergenName(allergen)),
                    selected: viewModel.dietaryRestrictions.contains(allergen),
                    onSelected: (selected) {
                      if (selected) {
                        viewModel.addDietaryRestrictions([allergen]);
                      } else {
                        viewModel.dietaryRestrictions.remove(allergen);
                        viewModel.notifyListeners();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
            if (viewModel.isSearching && viewModel.searchResults.isEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "No results found",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
            if (viewModel.dietaryRestrictions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  "Please select at least one dietary restriction",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
      // Third page - Health Goals
      OnboardingPage(
        title: "Health Goals",
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeightSlider(viewModel),
            _buildWeightSlider(viewModel),
            _buildActivityLevel(viewModel),
            const Text(
              "Your Goals",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.5),
              children: Goal.values.map((goal) {
                return _buildSectionTitle(
                  viewModel,
                  _getGoalIcon(goal),
                  _formatGoal(goal),
                  "",
                  isPressable: true,
                  isSelected: viewModel.healthGoals.contains(goal),
                );
              }).toList(),
            ),
            _buildCalorieTarget(viewModel),
          ],
        ),
      ),
    ];
  }

  Widget _buildHeightSlider(OnboardingViewmodel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Height", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Slider(
          value: viewModel.height,
          min: 140,
          max: 200,
          divisions: 60,
          label: "${viewModel.height.round()}cm",
          onChanged: (value) => viewModel.setHeight(value),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("140cm"),
            Text("200cm"),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightSlider(OnboardingViewmodel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Weight", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Slider(
          value: viewModel.weight,
          min: 40,
          max: 120,
          divisions: 80,
          label: "${viewModel.weight.round()}kg",
          onChanged: (value) => viewModel.setWeight(value),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("40kg"),
            Text("120kg"),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevel(OnboardingViewmodel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Activity Level",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<ActivityLevel>(
            value: viewModel.activityLevel,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: ActivityLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(_formatActivityLevel(level)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.setActivityLevel(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTarget(OnboardingViewmodel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Daily Calorie Target",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${viewModel.dailyCalorieTarget}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(
                  text: " kcal",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Based on your profile and goals",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Adjust Daily Calorie Target'),
                  content: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Slide to adjust your daily calorie target',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: viewModel.dailyCalorieTarget.toDouble(),
                            min: 1200,
                            max: 4000,
                            divisions: 280,
                            label: "${viewModel.dailyCalorieTarget} kcal",
                            onChanged: (value) {
                              setState(() {
                                viewModel.setDailyCalorieTarget(value.round());
                              });
                            },
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("1200 kcal"),
                              Text("4000 kcal"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Current target: ${viewModel.dailyCalorieTarget} kcal",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Adjust Manually",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getAllergenIcon(CommonAllergens allergen) {
    switch (allergen) {
      case CommonAllergens.gluten:
        return ImageConstants.glutenIcon;
      case CommonAllergens.lactose:
        return ImageConstants.lactoseIcon;
      case CommonAllergens.eggs:
        return ImageConstants.eggIcon;
      case CommonAllergens.shellfish:
        return ImageConstants.fishIcon;
      default:
        return ImageConstants.dietetaryPreferencesIcon;
    }
  }

  String _getGoalIcon(Goal goal) {
    switch (goal) {
      case Goal.loseWeight:
        return ImageConstants.loseWeightIcon;
      case Goal.gainMuscle:
        return ImageConstants.gainMuscleIcon;
      case Goal.maintainWellness:
        return ImageConstants.maintainWellnessIcon;
      case Goal.betterNutrition:
        return ImageConstants.betterNutritionIcon;
    }
  }

  String _formatAllergenName(CommonAllergens allergen) {
    return allergen
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }

  String _formatActivityLevel(ActivityLevel level) {
    return level
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }

  String _formatGoal(Goal goal) {
    return goal
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OnboardingViewmodel>();

    return Column(
      children: [
        _buildPageIndicator(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _buildPages(viewModel).length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildPages(viewModel)[index],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: (_currentPage == 1 &&
                      viewModel.dietaryRestrictions.isEmpty)
                  ? null
                  : () async {
                      if (_currentPage < _buildPages(viewModel).length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        try {
                          await viewModel.finalizeOnboarding(context);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      }
                    },
              child: Text(
                _currentPage == _buildPages(viewModel).length - 1
                    ? "Complete Registration"
                    : "Continue",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          _buildPages(context.watch<OnboardingViewmodel>()).length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black : Colors.grey,
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(
    OnboardingViewmodel viewModel,
    String icon,
    String header,
    String? body, {
    bool isPressable = false,
    bool isSelected = false,
  }) {
    final content = Card(
      color: isSelected ? Colors.black : Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageTransformers(icon).icon,
            const SizedBox(height: 2),
            Text(
              header,
              style: TextStyle(
                fontWeight: body == "" ? FontWeight.normal : FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            body == null
                ? const SizedBox.shrink()
                : Text(
                    body,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );

    return isPressable
        ? InkWell(
            onTap: () {
              if (_currentPage == 1) {
                // Map the header text to the corresponding CommonAllergens enum
                CommonAllergens? allergen;
                switch (header) {
                  case "Gluten":
                    allergen = CommonAllergens.gluten;
                    break;
                  case "Lactose":
                    allergen = CommonAllergens.lactose;
                    break;
                  case "Vegan":
                    allergen = CommonAllergens.soy;
                    break;
                  case "Shellfish":
                    allergen = CommonAllergens.shellfish;
                    break;
                  case "Eggs":
                    allergen = CommonAllergens.eggs;
                    break;
                  case "Nuts":
                    allergen = CommonAllergens.nuts;
                    break;
                }

                if (allergen != null) {
                  if (viewModel.dietaryRestrictions.contains(allergen)) {
                    viewModel.dietaryRestrictions.remove(allergen);
                  } else {
                    viewModel.addDietaryRestrictions([allergen]);
                  }
                  viewModel.notifyListeners();
                }
              } else if (_currentPage == 2) {
                final goal = Goal.values.firstWhere(
                  (g) => _formatGoal(g) == header,
                );
                if (viewModel.healthGoals.contains(goal)) {
                  viewModel.healthGoals.remove(goal);
                } else {
                  viewModel.addHealthGoals([goal]);
                }
                viewModel.notifyListeners();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: content,
          )
        : content;
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;

  const OnboardingPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 24),
        body,
      ],
    );
  }
}
