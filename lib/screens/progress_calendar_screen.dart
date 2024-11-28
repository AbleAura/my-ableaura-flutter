// progress_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';

class ProgressCalendarScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ProgressCalendarScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _ProgressCalendarScreenState createState() => _ProgressCalendarScreenState();
}

class _ProgressCalendarScreenState extends State<ProgressCalendarScreen> {
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
    return Scaffold(
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadEvaluations,
            child: _buildEvaluationsList(),
          ),
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
      ..sort((a, b) => b.compareTo(a)); // Sort by most recent

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length + 1, // +1 for the header
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Progress Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$totalEvaluations evaluations across ${_evaluations.length} days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(DateTime date, List<DailyProgress> evaluations) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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

// Day Progress Sheet Implementation
class DayProgressSheet extends StatelessWidget {
  final DateTime date;
  final List<DailyProgress> events;

  const DayProgressSheet({
    Key? key,
    required this.date,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) => _buildAssessmentCard(events[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${events.length} evaluations',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(DailyProgress assessment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assessment.skillName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLevelRow('Support', assessment.supportLevel),
            const SizedBox(height: 8),
            _buildLevelRow('Instruction', assessment.instructionLevel),
            const SizedBox(height: 8),
            _buildLevelRow('Performance', assessment.performanceLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(String label, String level) {
    final color = level == 'high' ? Colors.green :
                 level == 'medium' ? Colors.orange : Colors.red;
                 
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                level.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}