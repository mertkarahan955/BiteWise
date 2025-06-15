import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/view/meals_view.dart';
import 'package:bitewise/view/profile_view.dart';
import 'package:bitewise/view/home_view.dart';
import 'package:bitewise/viewmodel/meals_viewmodel.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/home_viewmodel.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isDataLoaded = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeView(),
      const MealsView(),
      const ProfileView(),
    ];
  }

  void _loadInitialData(BuildContext context) {
    if (!_isDataLoaded) {
      context.read<MealsViewmodel>().loadMealsAndPlan();
      context.read<ProfileViewmodel>().loadUserProfile();
      final userId = FirebaseService().currentUser?.uid;
      context.read<HomeViewmodel>().loadHomeData(userId: userId ?? '');
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
        ChangeNotifierProvider(
          create: (_) => HomeViewmodel(),
        ),
      ],
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadInitialData(context);
          });

          return Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom - 20
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
