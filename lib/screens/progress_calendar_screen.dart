// lib/screens/progress/progress_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:my_ableaura/screens/progress/components.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';
import '../../widgets/month_selector.dart';
import '../../widgets/month_selection_indicator.dart';
import 'progress/progress_calendar_screen.dart';

class ProgressCalendarScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final DateTime? initialMonth;

  const ProgressCalendarScreen({
    Key? key,
    required this.childId,
    required this.childName,
    this.initialMonth,
  }) : super(key: key);

  @override
  _ProgressCalendarScreenState createState() => _ProgressCalendarScreenState();
}

class _ProgressCalendarScreenState extends State<ProgressCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<DailyProgress>> _events;
  bool _isLoading = false;
  
  // Track months that have data
  Set<DateTime> _monthsWithData = {};
  
  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth ?? DateTime.now();
    _selectedDay = widget.initialMonth ?? DateTime.now();
    _events = {};
    _loadMonthEvents(_focusedDay);
    _loadMonthsWithData();
  }
  
  // Load months that have progress data
  Future<void> _loadMonthsWithData() async {
    try {
      // If you're using the mock implementation during development:
      final availableMonths = await StudentService.getAvailableProgressMonthsMock(widget.childId);
      
      // Once the API is available, switch to:
      // final availableMonths = await StudentService.getAvailableProgressMonths(widget.childId);
      
      if (mounted) {
        setState(() {
          _monthsWithData = availableMonths.map((date) => 
            DateTime(date.year, date.month)).toSet();
        });
      }
    } catch (e) {
      print('Error loading available months: $e');
    }
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

  void _selectMonth() async {
    await showMonthPicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 30)), // Allow up to next month
      onMonthSelected: (selectedMonth) {
        setState(() {
          _focusedDay = selectedMonth;
          _selectedDay = selectedMonth;
        });
        _loadMonthEvents(selectedMonth);
      },
    );
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
        // Custom month selector header
        _buildMonthHeader(),
        
        // Calendar Card
        Card(
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
            headerVisible: false, // Hide default header since we're providing our own
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              final events = _getEventsForDay(selectedDay);
              if (events.isNotEmpty) {
                _showDayProgress(selectedDay, events);
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadMonthEvents(focusedDay);
            },
          ),
        ),
        
        if (_isLoading)
          Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: MonthSummary(events: _events),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MonthSelectionIndicator(
          currentMonth: _focusedDay,
          onTap: _selectMonth,
          isLoading: _isLoading,
          tooltipMessage: 'Select month to view progress data',
        ),
        // If we have months with data, show the indicator
        if (_monthsWithData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: MonthDataIndicator(
              monthsWithData: _monthsWithData.toList(),
              currentMonth: _focusedDay,
              onMonthSelected: (selectedMonth) {
                setState(() {
                  _focusedDay = selectedMonth;
                  _selectedDay = selectedMonth;
                });
                _loadMonthEvents(selectedMonth);
              },
            ),
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
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'No evaluations recorded this month',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try selecting a different month',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(monthEvents, context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<DailyProgress> events, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).primaryColor,
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
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Text(
                  '${events.length} evaluation sessions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SkillsSummary(events: events),
          ],
        ),
      ),
    );
  }
}