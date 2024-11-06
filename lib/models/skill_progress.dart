import 'package:my_ableaura/models/progress_entry.dart';

class SkillProgress {
  final String skillName;
  final List<ProgressEntry> entries;

  SkillProgress({
    required this.skillName,
    required this.entries,
  });
}
