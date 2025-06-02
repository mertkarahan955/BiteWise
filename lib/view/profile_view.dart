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
                await context.read<FirebaseService>().createBulkMealPlans();
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
                ProgressTrackerCard(user: user),
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
  const ProgressTrackerCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Dummy data for demonstration
    final double progress = 0.75;
    final int calories = 1200;
    final int calorieTarget = 1500;
    final int protein = 65;
    final int proteinTarget = 80;
    final int water = 6;
    final int waterTarget = 8;
    final int adherence = 85;

    return Card(
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
                      width: 200,
                      child: GridView.count(
                        crossAxisCount: 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 2,
                        childAspectRatio: 5,
                        children: user.healthGoals.map((goal) {
                          final iconPath = _getGoalIconPath(goal);
                          return Chip(
                            avatar: iconPath != null
                                ? SvgPicture.asset(
                                    iconPath,
                                    width: 20,
                                    height: 20,
                                  )
                                : null,
                            label: Text(_formatGoal(goal)),
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF5B5FE9)),
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
            Row(
              children: [
                Expanded(
                  child: _StatProgress(
                    label: 'Calories',
                    value: calories,
                    target: calorieTarget,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatProgress(
                    label: 'Protein',
                    value: protein,
                    target: proteinTarget,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatProgress(
                    label: 'Water',
                    value: water,
                    target: waterTarget,
                    unit: 'cups',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatProgress(
                    label: 'Adherence',
                    value: adherence,
                    target: 100,
                    isPercent: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Log Meal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.opacity),
                    label: const Text('Add Water'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                    label: const Text('Voice In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              isPercent
                  ? '$value%'
                  : '$value/${target}${unit != null ? ' $unit' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
