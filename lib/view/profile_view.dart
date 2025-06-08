import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/goal.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bitewise/services/firebase_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:fl_chart/fl_chart.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthViewmodel>().logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Upload Mock Data'),
                  content: const Text(
                    'This will upload sample meals to the database. This action cannot be undone. Are you sure you want to continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          await context.read<FirebaseService>().addMockMeals();

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Mock data uploaded successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error uploading mock data: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Create Meal Plans',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              try {
                await context
                    .read<FirebaseService>()
                    .addMockMealPlansForCurrentUser();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal plans created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating meal plans: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ProfileViewmodel>(
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
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadUserProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = viewModel.user;
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight Card
                WeightCardPager(
                  currentWeight: viewModel.currentWeight,
                  targetWeight: viewModel.targetWeight,
                  onWeightChanged: (newWeight) async {
                    await viewModel.updateTodayWeight(newWeight);
                    await viewModel.loadWeightHistory();
                  },
                  isLoading:
                      viewModel.isLoading || viewModel.currentWeight == null,
                  weightHistory: viewModel.weightHistory,
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: context.read<ProfileViewmodel>().todayIntakeStream,
                  builder: (context, snapshot) {
                    final intake = snapshot.data;
                    return ProgressTrackerCard(user: user, intake: intake);
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildSection(
                      'Personal Information',
                      [
                        _buildInfoRow('Name', user.name ?? 'Not set'),
                        _buildInfoRow('Email', user.email ?? 'Not set'),
                        _buildInfoRow('Height', '${user.height} cm'),
                        _buildInfoRow('Weight', '${user.weight} kg'),
                        _buildInfoRow('Activity Level',
                            _formatActivityLevel(user.activityLevel)),
                        _buildInfoRow('Daily Calorie Target',
                            '${user.dailyCalorieTarget} kcal'),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildSection(
                      'Dietary Restrictions',
                      [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.dietaryRestrictions.map((allergen) {
                            return Chip(
                              label: Text(_formatAllergenName(allergen)),
                              backgroundColor: Colors.grey[200],
                              labelStyle:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatActivityLevel(ActivityLevel level) {
    return level
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }

  String _formatAllergenName(CommonAllergens allergen) {
    return allergen
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
}

class ProgressTrackerCard extends StatelessWidget {
  final UserModel user;
  final dynamic intake;
  final int? proteinTarget;
  final int? waterTarget;
  const ProgressTrackerCard(
      {super.key,
      required this.user,
      this.intake,
      this.proteinTarget,
      this.waterTarget});

  @override
  Widget build(BuildContext context) {
    final int calories = intake?.totalCalories?.round() ?? 0;
    final int calorieTarget = user.dailyCalorieTarget.round();
    final int protein = intake?.totalProtein?.round() ?? 0;
    final int proteinTarget = this.proteinTarget ?? 80;
    final int water = intake?.totalWater ?? 0;
    final int waterTarget = this.waterTarget ?? 8;
    final int adherence = 85;
    final double progress =
        calorieTarget > 0 ? (calories / calorieTarget).clamp(0, 1) : 0.0;

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Goals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 250,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            childAspectRatio: 1.80,
                            children: user.healthGoals.map((goal) {
                              final iconPath = _getGoalIconPath(goal);
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (iconPath != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12.0),
                                        child: SvgPicture.asset(
                                          iconPath,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    Flexible(
                                      child: Text(
                                        _formatGoal(goal),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF5B5FE9)),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B5FE9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StatProgress(
                  label: 'Calories',
                  value: calories,
                  target: calorieTarget,
                ),
                const SizedBox(height: 8),
                _StatProgress(
                  label: 'Protein',
                  value: protein,
                  target: proteinTarget,
                ),
                const SizedBox(height: 8),
                _StatProgress(
                  label: 'Carbs',
                  value: intake?.totalCarbs?.round() ?? 0,
                  target: 250, // TODO: AI'dan alınacak
                ),
                const SizedBox(height: 8),
                _StatProgress(
                  label: 'Fat',
                  value: intake?.totalFat?.round() ?? 0,
                  target: 70, // TODO: AI'dan alınacak
                ),
                const SizedBox(height: 8),
                _StatProgress(
                  label: 'Water',
                  value: water,
                  target: waterTarget,
                  unit: 'cups',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Water Intake',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                WaterCupsRow(water: water, waterTarget: waterTarget),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _getGoalIconPath(Goal goal) {
    final goalStr = goal.toString().split('.').last.toLowerCase();
    if (goalStr.contains('muscle')) return 'assets/icons/gain_muscle.svg';
    if (goalStr.contains('weight')) return 'assets/icons/lose_weight.svg';
    if (goalStr.contains('nutrition')) return 'assets/icons/apple.svg';
    if (goalStr.contains('wellness') || goalStr.contains('health')) {
      return 'assets/icons/heart.svg';
    }
    return null;
  }

  String _formatGoal(Goal goal) {
    return goal
        .toString()
        .split('.')
        .last
        .replaceAll(RegExp(r'(?=[A-Z])'), ' ');
  }
}

class _StatProgress extends StatelessWidget {
  final String label;
  final int value;
  final int target;
  final String? unit;
  final bool isPercent;
  const _StatProgress(
      {required this.label,
      required this.value,
      required this.target,
      this.unit,
      this.isPercent = false});

  @override
  Widget build(BuildContext context) {
    double percent = value / target;
    if (percent > 1) percent = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            Text(
              isPercent
                  ? '$value%'
                  : '$value/${target}${unit != null ? ' $unit' : ''}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B5FE9)),
          ),
        ),
      ],
    );
  }
}

// Water Intake bardaklarını gösteren widget
class WaterCupsRow extends StatefulWidget {
  final int water;
  final int waterTarget;
  const WaterCupsRow({required this.water, required this.waterTarget, Key? key})
      : super(key: key);

  @override
  State<WaterCupsRow> createState() => _WaterCupsRowState();
}

class _WaterCupsRowState extends State<WaterCupsRow> {
  int? _removingIndex;
  int? _selectedCupIndex;

  @override
  Widget build(BuildContext context) {
    int glassCount = widget.water == 0
        ? widget.waterTarget
        : (widget.water > widget.waterTarget
                ? widget.water
                : widget.waterTarget) +
            1;
    // Eğer bardak azaltılırsa ve bardak sayısı 8'den fazlaysa, boş bardak sayısını da azalt
    if (widget.water < widget.waterTarget &&
        glassCount > widget.waterTarget + 1) {
      glassCount = widget.waterTarget + 1;
    }
    return Wrap(
      spacing: 4,
      runSpacing: 8,
      children: List.generate(glassCount, (index) {
        final isFilled = index < widget.water;
        final isSelected = _selectedCupIndex == index;
        final isRemoving = _removingIndex == index;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                if (!isFilled) {
                  // Su ekle
                  final now = DateTime.now();
                  final date =
                      "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                  final firebaseService = context.read<FirebaseService>();
                  final uid = firebaseService.currentUser?.uid;
                  if (uid != null) {
                    await firebaseService.addWaterToDailyIntake(
                      userId: uid,
                      date: date,
                      amount: 1,
                    );
                  }
                } else {
                  // Dolu bardağa tıklayınca çarpı aç/kapa
                  setState(() {
                    if (_selectedCupIndex == index) {
                      _selectedCupIndex = null;
                    } else {
                      _selectedCupIndex = index;
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.local_drink,
                    size: 32,
                    color: isRemoving
                        ? Colors.red
                        : (isFilled ? Colors.blue : Colors.grey[300]),
                  ),
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _removingIndex = index;
                      _selectedCupIndex = null;
                    });
                    await Future.delayed(const Duration(milliseconds: 400));
                    setState(() {
                      _removingIndex = null;
                    });
                    // Su azalt
                    final now = DateTime.now();
                    final date =
                        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                    final firebaseService = context.read<FirebaseService>();
                    final uid = firebaseService.currentUser?.uid;
                    if (uid != null) {
                      await firebaseService.addWaterToDailyIntake(
                        userId: uid,
                        date: date,
                        amount: -1,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class WeightCardPager extends StatefulWidget {
  final double? currentWeight;
  final double? targetWeight;
  final void Function(double) onWeightChanged;
  final bool isLoading;
  final List<WeightEntry> weightHistory;

  const WeightCardPager({
    required this.currentWeight,
    required this.targetWeight,
    required this.onWeightChanged,
    required this.isLoading,
    required this.weightHistory,
    super.key,
  });

  @override
  State<WeightCardPager> createState() => _WeightCardPagerState();
}

class _WeightCardPagerState extends State<WeightCardPager> {
  int _page = 0;
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              WeightCard(
                currentWeight: widget.currentWeight,
                targetWeight: widget.targetWeight,
                onWeightChanged: widget.onWeightChanged,
                isLoading: widget.isLoading,
              ),
              WeightHistoryChart(weightHistory: widget.weightHistory),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              2,
              (i) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _page == i
                          ? const Color(0xFF5B5FE9)
                          : Colors.grey[400],
                    ),
                  )),
        ),
      ],
    );
  }
}

class WeightHistoryChart extends StatelessWidget {
  final List<WeightEntry> weightHistory;
  const WeightHistoryChart({required this.weightHistory, super.key});

  @override
  Widget build(BuildContext context) {
    if (weightHistory.isEmpty) {
      return const Center(child: Text('No weight history'));
    }
    final spots = weightHistory
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              e.value.weight,
            ))
        .toList();

    // X axis: day.month
    List<String> xLabels = weightHistory.map((e) {
      final date = DateTime.tryParse(e.date) ?? DateTime.now();
      return "${date.day}.${date.month}";
    }).toList();

    // Y axis: min/max kilo, aralığı daha geniş ve yuvarlanmış tut
    final weights = weightHistory.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxWeight - minWeight).abs();
    final padding = range < 2 ? 1 : (range * 0.2).clamp(1, 5);
    final minY = (minWeight - padding).floorToDouble();
    final maxY = (maxWeight + padding).ceilToDouble();
    final yInterval = range < 5 ? 1 : 4;

    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kilo Geçmişi',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: yInterval.toDouble(),
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.black12, strokeWidth: 1),
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: yInterval.toDouble(),
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval:
                            (xLabels.length / 4).ceilToDouble().clamp(1, 7),
                        getTitlesWidget: (value, meta) {
                          int idx = value.round();
                          if (idx < 0 || idx >= xLabels.length)
                            return const SizedBox.shrink();
                          return Text(
                            xLabels[idx],
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Color(0xFF5B5FE9),
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightCard extends StatelessWidget {
  final double? currentWeight;
  final double? targetWeight;
  final void Function(double) onWeightChanged;
  final bool isLoading;

  const WeightCard({
    required this.currentWeight,
    required this.targetWeight,
    required this.onWeightChanged,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 8),
                  const Text('Kilo',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text('Hedef: ${targetWeight?.toStringAsFixed(1) ?? "-"} kg',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.black, size: 40),
                        onPressed: () {
                          if (currentWeight != null) {
                            onWeightChanged(
                                (currentWeight! - 0.1).clamp(0, 999));
                          }
                        },
                      ),
                      Text('${currentWeight?.toStringAsFixed(1) ?? "-"} kg',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.black, size: 40),
                        onPressed: () {
                          if (currentWeight != null) {
                            onWeightChanged(
                                (currentWeight! + 0.1).clamp(0, 999));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
