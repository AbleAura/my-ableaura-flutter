// lib/screens/progress/components.dart

import 'package:flutter/material.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';

class ProgressCard extends StatelessWidget {
  final DailyProgress progress;

  const ProgressCard({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              progress.skillName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              progress.subSkillName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                LevelBox(label: 'Support', level: progress.supportLevel),
                SizedBox(width: 8),
                LevelBox(label: 'Instruction', level: progress.instructionLevel),
                SizedBox(width: 8),
                LevelBox(label: 'Performance', level: progress.performanceLevel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LevelBox extends StatelessWidget {
  final String label;
  final String level;

  const LevelBox({
    Key? key,
    required this.label,
    required this.level,
  }) : super(key: key);

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _getLevelColor(level).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                level,
                style: TextStyle(
                  color: _getLevelColor(level),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// --------------------
/// Updated Overall Progress Tab
/// --------------------

class ProgressSummaryScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ProgressSummaryScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _ProgressSummaryScreenState createState() => _ProgressSummaryScreenState();
}

class _ProgressSummaryScreenState extends State<ProgressSummaryScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_allProgress.isEmpty) {
      return const Center(child: Text('No progress data available'));
    }

    return RefreshIndicator(
      onRefresh: _loadProgress,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMonthOverview(),
        ],
      ),
    );
  }

  Widget _buildMonthOverview() {
    // Group evaluations by day.
    final Map<DateTime, List<DailyProgress>> days = {};
    for (var progress in _allProgress) {
      final day = DateTime(
        progress.date.year,
        progress.date.month,
        progress.date.day,
      );
      days.putIfAbsent(day, () => []).add(progress);
    }
    final sortedDays = days.keys.toList()..sort();

    return Card(
      elevation: 2,
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
                  Icons.insights,
                  color: Colors.deepPurple,
                ),
                SizedBox(width: 8),
                Text(
                  'Month Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${_allProgress.length} evaluation sessions on ${sortedDays.length} days',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Reuse the SkillsSummary widget to show a summary by skills.
            SkillsSummary(events: _allProgress),
          ],
        ),
      ),
    );
  }
}

/// SkillsSummary widget from the calendar screen can be reused here.
class SkillsSummary extends StatelessWidget {
  final List<DailyProgress> events;

  const SkillsSummary({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group events by skill name.
    final skillGroups = events.fold<Map<String, List<DailyProgress>>>(
      {},
      (map, event) {
        map[event.skillName] = (map[event.skillName] ?? [])..add(event);
        return map;
      },
    );

    if (skillGroups.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...skillGroups.entries.map((entry) => _buildSkillProgressBar(context, entry.key, entry.value)).toList(),
      ],
    );
  }

  Widget _buildSkillProgressBar(BuildContext context, String skillName, List<DailyProgress> skillEvents) {
    // Calculate average values (this example assumes a numeric conversion).
    final avgSupport = skillEvents
        .map((e) => _getLevelValue(e.supportLevel))
        .reduce((a, b) => a + b) / skillEvents.length;
    final avgInstruction = skillEvents
        .map((e) => _getLevelValue(e.instructionLevel))
        .reduce((a, b) => a + b) / skillEvents.length;
    final avgPerformance = skillEvents
        .map((e) => _getLevelValue(e.performanceLevel))
        .reduce((a, b) => a + b) / skillEvents.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skillName,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildProgressIndicator('Support', avgSupport, context),
          const SizedBox(height: 4),
          _buildProgressIndicator('Instruction', avgInstruction, context),
          const SizedBox(height: 4),
          _buildProgressIndicator('Performance', avgPerformance, context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value, BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 10, // Assuming a maximum value of 10
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(value)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  double _getLevelValue(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 3.0;
      case 'medium':
        return 6.0;
      case 'high':
        return 9.0;
      default:
        return 1.0;
    }
  }

  Color _getLevelColor(double value) {
    if (value < 4) return Colors.red;
    if (value < 7) return Colors.orange;
    return Colors.green;
  }
}
