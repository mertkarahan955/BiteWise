import 'package:bitewise/models/activity_level.dart';
import 'package:bitewise/models/allergens_model.dart';
import 'package:bitewise/models/goal.dart';
import 'package:bitewise/models/daily_intake.dart';
import 'package:bitewise/viewmodel/profile_viewmodel.dart';
import 'package:bitewise/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitewise/models/user_model.dart';
import 'package:bitewise/models/weight_entry.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        backgroundColor: Colors.blue.shade700,
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
        ],
      ),
      body: Consumer<ProfileViewmodel>(
        builder: (context, viewModel, child) {
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
                    onPressed: () => viewModel.loadUserData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = viewModel.userData;
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
                // Profile Header with Avatar
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name ?? 'Not set',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? 'Not set',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Weight Card
                Consumer<ProfileViewmodel>(
                  builder: (context, viewModel, child) {
                    return WeightCardPager(
                      currentWeight: viewModel.currentWeight,
                      onWeightChanged: (newWeight) async {
                        await viewModel.updateTodayWeight(newWeight);
                      },
                      isLoading: viewModel.isLoading,
                      weightHistory: viewModel.weightHistory,
                    );
                  },
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: context.read<ProfileViewmodel>().todayIntakeStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final doc = snapshot.data as DocumentSnapshot;
                    final intake = doc.exists
                        ? DailyIntake.fromMap(
                            doc.data() as Map<String, dynamic>)
                        : null;
                    return ProgressTrackerCard(user: user, intake: intake);
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildSection(
                      'Personal Information',
                      [
                        _buildInfoRow(
                            'Height', '${user.height} cm', Icons.height),
                        _buildInfoRow('Weight', '${user.weight} kg',
                            Icons.monitor_weight),
                        _buildInfoRow(
                            'Activity Level',
                            _formatActivityLevel(user.activityLevel),
                            Icons.directions_run),
                        _buildInfoRow(
                            'Daily Calorie Target',
                            '${user.dailyCalorieTarget} kcal',
                            Icons.local_fire_department),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.white,
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
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[800],
                              ),
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
        Row(
          children: [
            Icon(
              _getSectionIcon(title),
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Personal Information':
        return Icons.person_outline;
      case 'Dietary Restrictions':
        return Icons.restaurant;
      case 'Current Goals':
        return Icons.flag;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
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

  Widget _buildStatProgress(String label, int value, int target,
      {String? unit, IconData? icon}) {
    double percent = value / target;
    if (percent > 1) percent = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            Text(
              unit != null ? '$value/$target $unit' : '$value/$target',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int calories = intake?.totalCalories?.round() ?? 0;
    final int calorieTarget = user.dailyCalorieTarget.round();
    final int protein = intake?.totalProtein?.round() ?? 0;
    final int proteinTarget = this.proteinTarget ?? 80;
    final int water = intake?.totalWater ?? 0;
    final int waterTarget = this.waterTarget ?? 8;
    final double progress =
        calorieTarget > 0 ? (calories / calorieTarget).clamp(0, 1) : 0.0;

    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          color: Colors.white,
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
                        Row(
                          children: [
                            Icon(
                              Icons.flag,
                              color: Colors.grey[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Current Goals',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 250,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.80,
                            children: user.healthGoals.map((goal) {
                              final iconPath = _getGoalIconPath(goal);
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (iconPath != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: SvgPicture.asset(
                                          iconPath,
                                          width: 20,
                                          height: 20,
                                          colorFilter: ColorFilter.mode(
                                              Colors.grey[700]!,
                                              BlendMode.srcIn),
                                        ),
                                      ),
                                    Flexible(
                                      child: Text(
                                        _formatGoal(goal),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.grey[800]),
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
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade700),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatProgress('Calories', calories, calorieTarget,
                    icon: Icons.local_fire_department),
                const SizedBox(height: 16),
                _buildStatProgress('Protein', protein, proteinTarget,
                    icon: Icons.fitness_center),
                const SizedBox(height: 16),
                _buildStatProgress(
                    'Carbs', intake?.totalCarbs?.round() ?? 0, 250,
                    icon: Icons.grain),
                const SizedBox(height: 16),
                _buildStatProgress('Fat', intake?.totalFat?.round() ?? 0, 70,
                    icon: Icons.water_drop),
                const SizedBox(height: 16),
                _buildStatProgress('Water', water, waterTarget,
                    unit: 'cups', icon: Icons.local_drink),
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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_drink,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWaterCupsRow(context, water, waterTarget),
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

  Widget _buildWaterCupsRow(BuildContext context, int water, int waterTarget) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
          waterTarget + (water >= waterTarget ? water - waterTarget + 1 : 0),
          (index) {
        final isFilled = index < water;
        return GestureDetector(
          onTap: () {
            if (index < water) {
              // If tapping a filled cup, decrease water intake
              context.read<ProfileViewmodel>().updateWaterIntake(water - 1);
            } else if (index < waterTarget || water >= waterTarget) {
              // If tapping an empty cup within target or after reaching target, increase water intake
              context.read<ProfileViewmodel>().updateWaterIntake(water + 1);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isFilled ? Colors.blue.shade700 : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: isFilled ? Colors.blue.shade700 : Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.local_drink,
              size: 24,
              color: isFilled ? Colors.white : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}

class WeightCardPager extends StatefulWidget {
  final double? currentWeight;
  final void Function(double) onWeightChanged;
  final bool isLoading;
  final List<WeightEntry> weightHistory;

  const WeightCardPager({
    required this.currentWeight,
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
          height: 200,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              WeightCard(
                key: ValueKey(widget.currentWeight),
                currentWeight: widget.currentWeight,
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
                      color:
                          _page == i ? Colors.blue.shade700 : Colors.grey[400],
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
            const Text('Weight History',
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
                      color: Colors.blue.shade700,
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

class WeightCard extends StatefulWidget {
  final double? currentWeight;
  final void Function(double) onWeightChanged;
  final bool isLoading;

  const WeightCard({
    required this.currentWeight,
    required this.onWeightChanged,
    this.isLoading = false,
    super.key,
  });

  @override
  State<WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends State<WeightCard> {
  late TextEditingController _currentWeightController;
  late FocusNode _currentWeightFocus;

  @override
  void initState() {
    super.initState();
    _currentWeightController = TextEditingController(
      text: widget.currentWeight?.toString() ?? "-",
    );
    _currentWeightFocus = FocusNode();
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    _currentWeightFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WeightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentWeight != oldWidget.currentWeight) {
      final newText = widget.currentWeight?.toString() ?? "-";
      if (_currentWeightController.text != newText) {
        _currentWeightController.text = newText;
      }
    }
  }

  void _handleCurrentWeightChange(String value) {
    final newWeight = double.tryParse(value);
    if (newWeight != null && newWeight > 0 && newWeight < 999) {
      widget.onWeightChanged(newWeight);
    } else {
      _currentWeightController.text = widget.currentWeight?.toString() ?? "-";
    }
    _currentWeightFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        _handleCurrentWeightChange(_currentWeightController.text);
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Current Weight',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: Colors.grey[600], size: 40),
                          onPressed: () {
                            if (widget.currentWeight != null) {
                              widget.onWeightChanged(
                                  (widget.currentWeight! - 0.1).clamp(0, 999));
                            }
                          },
                        ),
                        SizedBox(
                          width: 160,
                          child: TextField(
                            controller: _currentWeightController,
                            focusNode: _currentWeightFocus,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              suffixText: 'kg',
                              suffixStyle: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onSubmitted: _handleCurrentWeightChange,
                            onTap: () {
                              _currentWeightController.selection =
                                  TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    _currentWeightController.text.length,
                              );
                            },
                            onEditingComplete: () {
                              _handleCurrentWeightChange(
                                  _currentWeightController.text);
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: Colors.grey[600], size: 40),
                          onPressed: () {
                            if (widget.currentWeight != null) {
                              widget.onWeightChanged(
                                  (widget.currentWeight! + 0.1).clamp(0, 999));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
