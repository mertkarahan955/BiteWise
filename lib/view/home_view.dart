import 'package:bitewise/view/components/meal_card.dart';
import 'package:bitewise/view/components/shimmer_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/viewmodel/home_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final userId = context.read<HomeViewmodel>().userId;
      if (userId != null) {
        context.read<HomeViewmodel>().loadHomeData(userId: userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Consumer<HomeViewmodel>(
          builder: (context, viewModel, child) {
            if (viewModel.userId != null &&
                viewModel.homeData == null &&
                !viewModel.isLoading) {
              Future.microtask(
                  () => viewModel.loadHomeData(userId: viewModel.userId!));
            }

            return Column(
              children: [
                // Fixed Header
                viewModel.isLoading
                    ? const ShimmerHeaderWidget()
                    : const _HeaderWidget(),
                viewModel.isLoading
                    ? const ShimmerWeatherBannerWidget()
                    : const _WeatherBannerWidget(),

                // Scrollable Content
                Expanded(
                  child: Platform.isIOS
                      ? CupertinoScrollbar(
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              CupertinoSliverRefreshControl(
                                onRefresh: () async {
                                  print("onRefresh");
                                  final homeViewmodel =
                                      context.read<HomeViewmodel>();
                                  final userId = homeViewmodel.userId;
                                  if (userId != null) {
                                    print("userId: $userId");
                                    await homeViewmodel.loadHomeData(
                                        userId: userId);
                                  }
                                },
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Row(
                                        children: const [
                                          Expanded(child: CalorieWidget()),
                                          Expanded(child: WaterTrackerWidget()),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      child: Text('Weekly Progress',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                    ),
                                    const WeeklyProgressWidget(),
                                    const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      child: Text("Today's Highlights",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                    ),
                                    const MealOfTheDayWidget(),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            print("onRefresh");
                            final homeViewmodel = context.read<HomeViewmodel>();
                            final userId = homeViewmodel.userId;
                            if (userId != null) {
                              print("userId: $userId");
                              await homeViewmodel.loadHomeData(userId: userId);
                            }
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(0),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: const [
                                    Expanded(child: CalorieWidget()),
                                    Expanded(child: WaterTrackerWidget()),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: Text('Weekly Progress',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                              ),
                              const WeeklyProgressWidget(),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                child: Text("Today's Highlights",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17)),
                              ),
                              const MealOfTheDayWidget(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        final data = viewModel.homeData;
        final today = DateFormat('EEEE, MMM d').format(DateTime.now());
        if (data == null) return const SizedBox.shrink();
        return Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, ${data.userName}!',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(today,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundImage: data.profileImageUrl.isNotEmpty
                    ? NetworkImage(data.profileImageUrl)
                    : null,
                child: data.profileImageUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherBannerWidget extends StatelessWidget {
  const _WeatherBannerWidget();
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        final data = viewModel.homeData;
        if (data == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.cloud, color: Colors.black87),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.weatherBanner.suggestionText,
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CalorieWidget extends StatefulWidget {
  const CalorieWidget({super.key});
  @override
  State<CalorieWidget> createState() => _CalorieWidgetState();
}

class _CalorieWidgetState extends State<CalorieWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const ShimmerCalorieWidget();
        }

        final data = viewModel.homeData;
        if (data == null) return const SizedBox.shrink();
        return Container(
          height: 110,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: data.calorieGoal == 0
                            ? 0
                            : data.dailyCalories / data.calorieGoal,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                      ),
                      Center(
                        child: Text(
                          data.calorieGoal == 0
                              ? '0%'
                              : '${((data.dailyCalories / data.calorieGoal) * 100).round()}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('${data.dailyCalories}/${data.calorieGoal} kcal',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WaterTrackerWidget extends StatefulWidget {
  const WaterTrackerWidget({super.key});
  @override
  State<WaterTrackerWidget> createState() => _WaterTrackerWidgetState();
}

class _WaterTrackerWidgetState extends State<WaterTrackerWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const ShimmerWaterTrackerWidget();
        }

        final data = viewModel.homeData;
        if (data == null) return const SizedBox.shrink();
        return Container(
          height: 110,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(data.waterGoal, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.opacity,
                        size: 22,
                        color: i < data.waterDrank
                            ? Colors.black87
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  data.waterDrank >= data.waterGoal
                      ? 'Goal achieved! 🎉'
                      : '${data.waterGoal - data.waterDrank} glasses to go!',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const ShimmerWeeklyProgress();
        }

        final data = viewModel.homeData;
        if (data == null) return const SizedBox.shrink();
        final weekly = data.weeklyProgress;
        final maxCal = weekly.isNotEmpty
            ? (weekly.reduce((a, b) => a > b ? a : b)).toDouble()
            : 100.0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCal == 0 ? 100 : maxCal * 1.2,
                  minY: 0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: maxCal > 0 ? (maxCal / 4).ceilToDouble() : 25,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          int idx = value.toInt();
                          if (idx < 0 || idx >= days.length)
                            return const SizedBox.shrink();
                          return Text(days[idx],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey));
                        },
                        reservedSize: 28,
                        interval: 1,
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                      show: true,
                      horizontalInterval:
                          maxCal > 0 ? (maxCal / 4).ceilToDouble() : 25),
                  barGroups: List.generate(7, (i) {
                    final y = (weekly.length > i ? weekly[i].toDouble() : 0);
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: y.toDouble(),
                          color: Colors.blue.shade600,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MealOfTheDayWidget extends StatelessWidget {
  const MealOfTheDayWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewmodel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const ShimmerMealOfTheDay();
        }

        final data = viewModel.homeData;
        if (data == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: MealCard(
                  meal: data.mealOfTheDay.toMeal(),
                  mealType: "Lunch",
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }
}
