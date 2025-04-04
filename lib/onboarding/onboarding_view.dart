import 'package:bitewise/auth/auth_view.dart';
import 'package:bitewise/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:bitewise/utils/image.dart';

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
  double _height = 170;
  double _weight = 70;

  List<OnboardingPage> get _pages => [
        OnboardingPage(
          title: "Welcome to BiteWise!",
          subtitle: "Let's help you get started with a personalized experience",
          body: GridView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            children: [
              _buildSectionTitle(ImageConstants.restaurantGuideIcon, "Restaurant Guide", "Find safe dining options", isPressable: true),
              _buildSectionTitle(ImageConstants.dietetaryPreferencesIcon, "Dietary Preferences", "Set your restrictions", isPressable: true),
              _buildSectionTitle(ImageConstants.alertRemindersIcon, "Alerts & Reminders", "Stay informed", isPressable: true),
              _buildSectionTitle(ImageConstants.socialIcon, "Social Features", "Connect with others", isPressable: true),
            ],
          ),
        ),
        OnboardingPage(
          title: "Let's Personalize Your Experience",
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                children: [
                  _buildSectionTitle(ImageConstants.glutenIcon, "Gluten", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.lactoseIcon, "Lactose", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.veganIcon, "Vegan", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.fishIcon, "Shellfish", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.eggIcon, "Eggs", "", isPressable: true),
                ],
              ),
              const Text(
                "Additional Dietary Restrictions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelStyle: const TextStyle(fontSize: 12),
                  prefixIconConstraints: const BoxConstraints(minWidth: 6, minHeight: 6),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ImageTransformers(ImageConstants.searchicon).icon,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  labelText: 'Search other dietary restrictions',
                ),
              ),
            ],
          ),
        ),
        OnboardingPage(
          title: "Health Goals",
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeightSlider(),
              _buildWeightSlider(),
              _buildActivityLevel(),
              Text("Your Goals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                children: [
                  _buildSectionTitle(ImageConstants.loseWeightIcon, "Lose Weight", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.gainMuscleIcon, "Gain Muscle", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.maintainWellnessIcon, "Maintain Wellness", "", isPressable: true),
                  _buildSectionTitle(ImageConstants.betterNutritionIcon, "Better Nutrition", "", isPressable: true),
                ],
              ),
              _buildCalorieTarget()
            ],
          ),
        ),
      ];

  Widget _buildSectionTitle(String icon, String header, String? body, {bool isPressable = false, bool isSelected = false}) {
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
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: content,
          )
        : content;
  }

  Widget _buildHeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Height", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Slider(
          value: _height,
          min: 140,
          max: 200,
          divisions: 60,
          label: "${_height.round()}cm",
          onChanged: (value) => setState(() => _height = value),
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

  Widget _buildWeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Weight", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Slider(
          value: _weight,
          min: 40,
          max: 120,
          divisions: 80,
          label: "${_weight.round()}kg",
          onChanged: (value) => setState(() => _weight = value),
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

  Widget _buildActivityLevel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity Level",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: "Sedentary",
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(
                value: "Sedentary",
                child: Text("Sedentary"),
              ),
              // Add more activity levels here
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTarget() {
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
            text: const TextSpan(
              children: [
                TextSpan(
                  text: "2,100",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
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
              // Handle manual adjustment
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageIndicator(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _pages[index],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pushReplacementNamed(
                    Routes.authPageKey,
                    arguments: AuthMode.signup,
                  );
                }
              },
              child: Text(
                _currentPage == _pages.length - 1 ? "Get Started" : "Continue",
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
      children: List.generate(_pages.length, (index) {
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
