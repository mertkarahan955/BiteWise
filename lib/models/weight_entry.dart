class WeightEntry {
  final String date; // yyyy-MM-dd
  final double weight;

  WeightEntry({required this.date, required this.weight});

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      date: map['date'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'weight': weight,
    };
  }
}
