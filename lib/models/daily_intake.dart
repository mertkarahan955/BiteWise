class DailyIntake {
  final String date; // yyyy-MM-dd
  final List<String> mealIds;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int totalWater; // bardak/cup

  DailyIntake({
    required this.date,
    required this.mealIds,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalWater,
  });

  factory DailyIntake.fromMap(Map<String, dynamic> map) {
    return DailyIntake(
      date: map['date'] ?? '',
      mealIds: List<String>.from(map['mealIds'] ?? []),
      totalCalories: (map['totalCalories'] ?? 0.0).toDouble(),
      totalProtein: (map['totalProtein'] ?? 0.0).toDouble(),
      totalCarbs: (map['totalCarbs'] ?? 0.0).toDouble(),
      totalFat: (map['totalFat'] ?? 0.0).toDouble(),
      totalWater: (map['totalWater'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mealIds': mealIds,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'totalWater': totalWater,
    };
  }
}
