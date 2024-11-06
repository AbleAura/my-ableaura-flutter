// lib/screens/progress/progress_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:my_ableaura/screens/progress/components.dart';
import 'package:table_calendar/table_calendar.dart';
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
        widget.childId,
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

  void _showDayProgress(DateTime selectedDay, List<DailyProgress> events) {
    if (events.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayProgressSheet(
        date: selectedDay,
        events: events,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              _showDayProgress(selectedDay, events);
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
            child: MonthSummary(events: _events),
          ),
      ],
    );
  }
}

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
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) => ProgressCard(
                progress: events[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM d, yyyy').format(date),
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
    );
  }
}

class MonthSummary extends StatelessWidget {
  final Map<DateTime, List<DailyProgress>> events;

  const MonthSummary({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthEvents = events.values.expand((e) => e).toList();
    if (monthEvents.isEmpty) {
      return Center(
        child: Text(
          'No evaluations recorded this month',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildSummaryCard(monthEvents),
      ],
    );
  }

  Widget _buildSummaryCard(List<DailyProgress> events) {
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
              '${events.length} evaluation sessions',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            SkillsSummary(events: events),
          ],
        ),
      ),
    );
  }
}

class SkillsSummary extends StatelessWidget {
  final List<DailyProgress> events;

  const SkillsSummary({
    Key? key,
    required this.events,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        return SkillProgressCard(
          skillName: entry.key,
          progressEntries: entry.value,
        );
      }).toList(),
    );
  }
}