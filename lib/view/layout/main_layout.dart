import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/view/meals_view.dart';
import 'package:bitewise/view/profile_view.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isDataLoaded = false;

  final List<Widget> _pages = [
    const MealsView(),
    const ProfileView(),
  ];

  void _loadInitialData(BuildContext context) {
    if (!_isDataLoaded) {
      context.read<MealsViewmodel>().loadMealsAndPlan();
      context.read<ProfileViewmodel>().loadUserProfile();
      _isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MealsViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewmodel(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Load data only once after providers are created
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadInitialData(context);
          });

          return Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Meals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
