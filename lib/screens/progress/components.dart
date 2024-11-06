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
            if (progress.notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                progress.notes,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
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

class SkillProgressCard extends StatelessWidget {
  final String skillName;
  final List<DailyProgress> progressEntries;

  const SkillProgressCard({
    Key? key,
    required this.skillName,
    required this.progressEntries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avgSupport = progressEntries
        .map((e) => e.getLevelValue(e.supportLevel))
        .reduce((a, b) => a + b) / progressEntries.length;
    final avgInstruction = progressEntries
        .map((e) => e.getLevelValue(e.instructionLevel))
        .reduce((a, b) => a + b) / progressEntries.length;
    final avgPerformance = progressEntries
        .map((e) => e.getLevelValue(e.performanceLevel))
        .reduce((a, b) => a + b) / progressEntries.length;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skillName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              ProgressIndicator(label: 'Support', value: avgSupport),
              SizedBox(width: 8),
              ProgressIndicator(label: 'Instruction', value: avgInstruction),
              SizedBox(width: 8),
              ProgressIndicator(label: 'Performance', value: avgPerformance),
            ],
          ),
        ],
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final String label;
  final double value;

  const ProgressIndicator({
    Key? key,
    required this.label,
  required this.value,
  }) : super(key: key);

  Color _getLevelColor(double value) {
    if (value <= 1) return Colors.red;
    if (value <= 2) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 3,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(value)),
          ),
        ],
      ),
    );
  }
}

// Add the ProgressSummaryScreen for overall progress
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
  ProgressSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await StudentService.getProgressSummary(widget.childId);
      setState(() => _summary = summary);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress summary: $e')),
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

    if (_summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load progress summary'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSummary,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildOverallProgress(),
        SizedBox(height: 16),
        _buildAIAnalysis(),
        SizedBox(height: 16),
        _buildImprovementsCard(),
        SizedBox(height: 16),
        _buildAreasForFocusCard(),
        SizedBox(height: 16),
        _buildRecommendationsCard(),
      ],
    );
  }

  Widget _buildOverallProgress() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                value: _summary!.overallProgress / 100,
                backgroundColor: Colors.grey[200],
                strokeWidth: 10,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_summary!.overallProgress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysis() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome),
                SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _summary!.aiAnalysis,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementsCard() {
    return _buildListCard(
      title: 'Key Improvements',
      icon: Icons.trending_up,
      items: _summary!.keyImprovements,
      color: Colors.green,
    );
  }

  Widget _buildAreasForFocusCard() {
    return _buildListCard(
      title: 'Areas for Focus',
      icon: Icons.track_changes,
      items: _summary!.areasForFocus,
      color: Colors.orange,
    );
  }

  Widget _buildRecommendationsCard() {
    return _buildListCard(
      title: 'Recommendations',
      icon: Icons.lightbulb_outline,
      items: _summary!.recommendations,
      color: Colors.purple,
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required MaterialColor color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}