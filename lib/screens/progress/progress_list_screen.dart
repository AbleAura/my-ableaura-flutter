import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';
import 'day_progress_sheet.dart';

class ProgressListScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ProgressListScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _ProgressListScreenState createState() => _ProgressListScreenState();
}

class _ProgressListScreenState extends State<ProgressListScreen> {
  bool _isLoading = false;
  Map<DateTime, List<DailyProgress>> _evaluations = {};

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() => _isLoading = true);
    try {
      final progressList = await StudentService.getMonthlyProgress(
        widget.childId,
        DateTime.now(),
      );
      
      final groupedProgress = <DateTime, List<DailyProgress>>{};
      for (var progress in progressList) {
        final date = DateTime(
          progress.date.year,
          progress.date.month,
          progress.date.day,
        );
        if (!groupedProgress.containsKey(date)) {
          groupedProgress[date] = [];
        }
        groupedProgress[date]!.add(progress);
      }

      setState(() {
        _evaluations = groupedProgress;
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
    return _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : RefreshIndicator(
          onRefresh: _loadEvaluations,
          child: _buildEvaluationsList(),
        );
  }

 Widget _buildEvaluationsList() {
    if (_evaluations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No evaluations recorded',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final sortedDates = _evaluations.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length + 1, // +1 for header only now
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        final date = sortedDates[index - 1];
        final evaluations = _evaluations[date]!;
        return _buildEvaluationCard(date, evaluations);
      },
    );
  }

  Widget _buildHeader() {
    final totalEvaluations = _evaluations.values
        .fold(0, (sum, list) => sum + list.length);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 8),
                Text(
                  'Progress Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$totalEvaluations evaluations across ${_evaluations.length} ${_evaluations.length == 1 ? 'day' : 'days'}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    final allEvaluations = _evaluations.values.expand((e) => e).toList();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightText(allEvaluations),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightText(List<DailyProgress> evaluations) {
    // Group skills by performance level along with their subskills
    final highPerformanceSkills = _groupSkillsByLevel(evaluations, 'high');
    final needsFocusSkills = _groupSkillsByLevel(evaluations, 'low');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (highPerformanceSkills.isNotEmpty) ...[
          const Text(
            '💪 Areas of Excellence:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
              fontSize: 15,
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
        if (evaluations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildOverallProgress(evaluations),
        ],
      ],
    );
  }

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
          const SizedBox(height: 8),
          Text(
            isExcellent 
              ? 'Showing strong proficiency in these skills'
              : 'Additional practice recommended for improvement',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(List<DailyProgress> evaluations) {
    final totalSkills = evaluations.length;
    final highCount = evaluations.where((e) => e.performanceLevel == 'high').length;
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

  Widget _buildEvaluationCard(DateTime date, List<DailyProgress> evaluations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDayProgress(date, evaluations),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${evaluations.length} skills',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Skills: ${evaluations.map((e) => e.skillName).toSet().join(', ')}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPerformanceIndicator(evaluations),
                  const Spacer(),
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceIndicator(List<DailyProgress> evaluations) {
    final total = evaluations.length;
    final highCount = evaluations.where((e) => e.performanceLevel == 'high').length;
    final mediumCount = evaluations.where((e) => e.performanceLevel == 'medium').length;
    
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: highCount > total / 2 ? Colors.green :
                mediumCount > total / 2 ? Colors.orange : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          highCount > total / 2 ? 'High Performance' :
          mediumCount > total / 2 ? 'Moderate Progress' : 'Needs Focus',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDayProgress(DateTime date, List<DailyProgress> evaluations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayProgressSheet(
        date: date,
        events: evaluations,
      ),
    );
  }
}