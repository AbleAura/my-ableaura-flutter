// lib/screens/progress/day_progress_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/progress_models.dart';

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
            _buildAIInsightsForDay(), // Add this
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
 Widget _buildAIInsightsForDay() {
    final highPerformance = events.where((e) => e.performanceLevel == 'high').length;
    final total = events.length;
    final percentage = ((highPerformance / total) * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'Daily Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Performed well in $percentage% of skills today. ' +
            (percentage > 70 
              ? 'Excellent progress!'
              : percentage > 40 
                ? 'Steady improvement.'
                : 'Focus on building fundamentals.'),
            style: const TextStyle(
              height: 1.5,
              fontSize: 14,
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
            if (assessment.subSkillName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                assessment.subSkillName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildLevelRow('Support', assessment.supportLevel),
            const SizedBox(height: 8),
            _buildLevelRow('Instruction', assessment.instructionLevel),
            const SizedBox(height: 8),
            _buildLevelRow('Performance', assessment.performanceLevel),
            const SizedBox(height: 16),
            if (assessment.performanceLevel == 'low') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This skill needs additional focus and practice',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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