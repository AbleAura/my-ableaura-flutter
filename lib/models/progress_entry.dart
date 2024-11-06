class ProgressEntry {
  final DateTime date;
  final String level;
  final String category; // Support, Instruction, or Performance

  ProgressEntry({
    required this.date,
    required this.level,
    required this.category,
  });

  // Convert level to numeric value for charts
  int get levelValue {
    switch (level.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      default:
        return 0;
    }
  }
}