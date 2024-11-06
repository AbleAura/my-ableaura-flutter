// progress_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/progress_models.dart';
import '../services/student_service.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<DailyProgress>> _events;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _loadMonthEvents(_focusedDay);
  }

  Future<void> _loadMonthEvents(DateTime month) async {
    setState(() => _isLoading = true);
    try {
      final progressList = await StudentService.getMonthlyProgress(
        1, // Replace with actual childId
        month,
      );
      
      setState(() {
        _events = progressList.fold<Map<DateTime, List<DailyProgress>>>({}, 
          (map, progress) {
            final date = DateTime(
              progress.date.year,
              progress.date.month,
              progress.date.day,
            );
            if (!map.containsKey(date)) {
              map[date] = [];
            }
            map[date]!.add(progress);
            return map;
          },
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<DailyProgress> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _showDayProgress(List<DailyProgress> events) {
    if (events.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM d, yyyy').format(_selectedDay),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildProgressCard(event);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(DailyProgress progress) {
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
                _buildLevelBox('Support', progress.supportLevel),
                SizedBox(width: 8),
                _buildLevelBox('Instruction', progress.instructionLevel),
                SizedBox(width: 8),
                _buildLevelBox('Performance', progress.performanceLevel),
              ],
            ),
            if (progress.notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(progress.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBox(String label, String level) {
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

  Widget _buildMonthSummary() {
    final monthEvents = _events.values.expand((e) => e).toList();
    if (monthEvents.isEmpty) {
      return Center(
        child: Text(
          'No evaluations recorded this month',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${monthEvents.length} evaluation sessions',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            _buildSkillsSummary(monthEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSummary(List<DailyProgress> events) {
    final skillGroups = events.fold<Map<String, List<DailyProgress>>>(
      {},
      (map, event) {
        if (!map.containsKey(event.skillName)) {
          map[event.skillName] = [];
        }
        map[event.skillName]!.add(event);
        return map;
      },
    );

    return Column(
      children: skillGroups.entries.map((entry) {
        final avgSupport = entry.value
            .map((e) => e.getLevelValue(e.supportLevel))
            .reduce((a, b) => a + b) / entry.value.length;
        final avgInstruction = entry.value
            .map((e) => e.getLevelValue(e.instructionLevel))
            .reduce((a, b) => a + b) / entry.value.length;
        final avgPerformance = entry.value
            .map((e) => e.getLevelValue(e.performanceLevel))
            .reduce((a, b) => a + b) / entry.value.length;

        return _buildSkillProgress(
          entry.key,
          avgSupport,
          avgInstruction,
          avgPerformance,
        );
      }).toList(),
    );
  }

  Widget _buildSkillProgress(
    String skillName,
    double supportLevel,
    double instructionLevel,
    double performanceLevel,
  ) {
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
              _buildProgressBar('Support', supportLevel),
              SizedBox(width: 8),
              _buildProgressBar('Instruction', instructionLevel),
              SizedBox(width: 8),
              _buildProgressBar('Performance', performanceLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value) {
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
            valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(
              value <= 1 ? 'low' : value <= 2 ? 'medium' : 'high',
            )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Progress Panel'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(8),
            child: TableCalendar<DailyProgress>(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final events = _getEventsForDay(selectedDay);
                _showDayProgress(events);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadMonthEvents(focusedDay);
              },
            ),
          ),
          if (_isLoading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: _buildMonthSummary(),
              ),
            ),
        ],
      ),
    );
  }
}