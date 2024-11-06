class DailyProgress {
  final DateTime date;
  final String skillName;
  final String subSkillName;
  final String supportLevel;
  final String instructionLevel;
  final String performanceLevel;
  final String notes;

  DailyProgress({
    required this.date,
    required this.skillName,
    required this.subSkillName,
    required this.supportLevel,
    required this.instructionLevel,
    required this.performanceLevel,
    this.notes = '',
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      skillName: json['skill_name'],
      subSkillName: json['sub_skill_name'],
      supportLevel: json['support_level'],
      instructionLevel: json['instruction_level'],
      performanceLevel: json['performance_level'],
      notes: json['notes'] ?? '',
    );
  }

  int getLevelValue(String level) {
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