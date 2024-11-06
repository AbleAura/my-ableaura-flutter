class ProgressSummary {
  final String overallProgress;
  final List<SkillAnalysis> skillAnalysis;
  final List<String> recommendations;
  final Map<String, double> skillScores;

  ProgressSummary({
    required this.overallProgress,
    required this.skillAnalysis,
    required this.recommendations,
    required this.skillScores,
  });
}

class SkillAnalysis {
  final String skillName;
  final String progress;
  final String trend; // 'improving', 'declining', 'stable'
  final double scoreChange;

  SkillAnalysis({
    required this.skillName,
    required this.progress,
    required this.trend,
    required this.scoreChange,
  });
}