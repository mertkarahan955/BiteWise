import 'package:bitewise/services/interfaces/i_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/view/meals_view.dart';
import 'package:bitewise/view/profile_view.dart';
import 'package:bitewise/view/home_view.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/home_viewmodel.dart';
import 'package:bitewise/utils/locator.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isDataLoaded = false;

  late final List<Widget> _pages;
  late final MealsViewmodel _mealsViewmodel;
  late final ProfileViewmodel _profileViewmodel;
  late final HomeViewmodel _homeViewmodel;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),
      const MealsView(),
      const ProfileView(),
    ];

    // Initialize viewmodels once
    _mealsViewmodel = locator<MealsViewmodel>();
    _profileViewmodel = locator<ProfileViewmodel>();
    _homeViewmodel = locator<HomeViewmodel>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    if (!_isDataLoaded) {
      final userId = locator<IFirebaseService>().currentUser?.uid;
      print("Loading initial data for user: $userId"); // Debug print

      if (userId != null) {
        // Load data sequentially to avoid race conditions
        _loadDataSequentially(userId);
      } else {
        print("No user ID found"); // Debug print
      }
    }
  }

  Future<void> _loadDataSequentially(String userId) async {
    try {
      print("Starting sequential data load"); // Debug print

      // Load home data first
      await _homeViewmodel.loadHomeData(userId: userId);
      print("Home data loaded"); // Debug print

      // Then load user data
      await _profileViewmodel.loadUserData();
      print("User data loaded"); // Debug print

      // Finally load meals
      await _mealsViewmodel.loadMeals();
      print("Meals loaded"); // Debug print

      if (mounted) {
        setState(() {
          _isDataLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _mealsViewmodel),
        ChangeNotifierProvider.value(value: _profileViewmodel),
        ChangeNotifierProvider.value(value: _homeViewmodel),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 8),
                child: Row(
                  children: List.generate(3, (index) {
                    final isSelected = _currentIndex == index;
                    IconData iconData;
                    String label;
                    switch (index) {
                      case 0:
                        iconData = Icons.home;
                        label = 'Home';
                        break;
                      case 1:
                        iconData = Icons.restaurant_menu;
                        label = 'Meals';
                        break;
                      case 2:
                        iconData = Icons.person;
                        label = 'Profile';
                        break;
                      default:
                        iconData = Icons.circle;
                        label = '';
                    }
                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 4,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              iconData,
                              color: isSelected ? Colors.black : Colors.grey,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
