import 'package:flutter/material.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';

class OverallProgressScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const OverallProgressScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _OverallProgressScreenState createState() => _OverallProgressScreenState();
}

class _OverallProgressScreenState extends State<OverallProgressScreen> {
  bool _isLoading = false;
  List<DailyProgress> _allProgress = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    try {
      final progressList = await StudentService.getMonthlyProgress(
        widget.childId,
        DateTime.now(),
      );
      setState(() {
        _allProgress = progressList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load progress data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allProgress.isEmpty) {
      return const Center(
        child: Text('No progress data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAIInsights(),
          const SizedBox(height: 16),
          _buildSkillBreakdown(),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    final highPerformanceSkills = _groupSkillsByLevel(_allProgress, 'high');
    final needsFocusSkills = _groupSkillsByLevel(_allProgress, 'low');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (highPerformanceSkills.isNotEmpty) ...[
              const Text(
                '💪 Areas of Excellence:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...highPerformanceSkills.entries.map((entry) => 
                _buildSkillDetail(
                  mainSkill: entry.key,
                  subSkills: entry.value,
                  isExcellent: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (needsFocusSkills.isNotEmpty) ...[
              const Text(
                '🎯 Areas for Focus:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...needsFocusSkills.entries.map((entry) => 
                _buildSkillDetail(
                  mainSkill: entry.key,
                  subSkills: entry.value,
                  isExcellent: false,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildOverallProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillBreakdown() {
    // Group all skills and their performance
    final skillGroups = <String, Map<String, int>>{};
    for (var progress in _allProgress) {
      if (!skillGroups.containsKey(progress.skillName)) {
        skillGroups[progress.skillName] = {
          'high': 0,
          'medium': 0,
          'low': 0,
        };
      }
      skillGroups[progress.skillName]![progress.performanceLevel] = 
        (skillGroups[progress.skillName]![progress.performanceLevel] ?? 0) + 1;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skills Breakdown',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...skillGroups.entries.map((entry) => 
              _buildSkillProgressBar(
                entry.key,
                entry.value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgressBar(String skillName, Map<String, int> counts) {
    final total = counts.values.fold(0, (sum, count) => sum + count);
    final highPercent = (counts['high'] ?? 0) / total;
    final mediumPercent = (counts['medium'] ?? 0) / total;
    final lowPercent = (counts['low'] ?? 0) / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skillName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                if (highPercent > 0)
                  Expanded(
                    flex: (highPercent * 100).round(),
                    child: Container(height: 8, color: Colors.green),
                  ),
                if (mediumPercent > 0)
                  Expanded(
                    flex: (mediumPercent * 100).round(),
                    child: Container(height: 8, color: Colors.orange),
                  ),
                if (lowPercent > 0)
                  Expanded(
                    flex: (lowPercent * 100).round(),
                    child: Container(height: 8, color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... Add all the helper methods from before (_buildSkillDetail, _groupSkillsByLevel, etc.)

  Map<String, List<String>> _groupSkillsByLevel(List<DailyProgress> evaluations, String level) {
    final skillsMap = <String, List<String>>{};
    
    for (var eval in evaluations) {
      if (eval.performanceLevel == level) {
        if (!skillsMap.containsKey(eval.skillName)) {
          skillsMap[eval.skillName] = [];
        }
        if (eval.subSkillName.isNotEmpty && 
            !skillsMap[eval.skillName]!.contains(eval.subSkillName)) {
          skillsMap[eval.skillName]!.add(eval.subSkillName);
        }
      }
    }
    
    return skillsMap;
  }

  Widget _buildSkillDetail({
    required String mainSkill,
    required List<String> subSkills,
    required bool isExcellent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isExcellent ? Colors.green : Colors.red).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isExcellent ? Colors.green : Colors.red).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExcellent ? Icons.star : Icons.flag,
                size: 16,
                color: isExcellent ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mainSkill,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (subSkills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specific areas:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...subSkills.map((subSkill) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subSkill,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverallProgress() {
    final totalSkills = _allProgress.length;
    final highCount = _allProgress.where((e) => e.performanceLevel == 'high').length;
    final percentage = ((highCount / totalSkills) * 100).round();

    String message;
    if (percentage > 70) {
      message = 'Outstanding progress! Keep up the excellent work! 🌟';
    } else if (percentage > 40) {
      message = 'Showing steady improvement. Continue building on this progress! 📈';
    } else {
      message = 'Focus on fundamentals and take one step at a time. You\'ve got this! 💪';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}