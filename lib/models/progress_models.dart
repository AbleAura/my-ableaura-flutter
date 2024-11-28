// progress_models.dart

class DailyProgress {
  final DateTime date;
  final String skillName;
  final String subSkillName;
  final String supportLevel;
  final String instructionLevel;
  final String performanceLevel;
  final DateTime evaluationTime;

  DailyProgress({
    required this.date,
    required this.skillName,
    required this.subSkillName,
    required this.supportLevel,
    required this.instructionLevel,
    required this.performanceLevel,
    required this.evaluationTime,
  });

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      date: DateTime.parse(json['date']),
      skillName: json['skill_name'],
      subSkillName: json['sub_skill_name'],
      supportLevel: _convertLevelToString(json['support_level']),
      instructionLevel: _convertLevelToString(json['instruction_level']),
      performanceLevel: _convertLevelToString(json['performance_level']),
      evaluationTime: DateTime.parse(json['evaluation_time']),
    );
  }

  static String _convertLevelToString(String level) {
    switch (level) {
      case '1':
        return 'low';
      case '5':
        return 'medium';
      case '10':
        return 'high';
      default:
        return 'low';
    }
  }

  int getLevelValue(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 5;
      case 'high':
        return 10;
      default:
        return 1;
    }
  }
}