import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/progress_models.dart';
import '../services/student_service.dart';
import '../services/insights_generator.dart';

class ProgressScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const ProgressScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<DailyProgress>> _events;
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _tabController = TabController(length: 2, vsync: this);
    _loadMonthEvents(_focusedDay);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthEvents(DateTime month) async {
    setState(() => _isLoading = true);
    try {
      final progressList = await StudentService.getMonthlyProgress(
        widget.studentId,
        month,
      );
      
      setState(() {
        _events = progressList.fold<Map<DateTime, List<DailyProgress>>>(
          {}, 
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

  List<DailyProgress> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FC), // Light purple background
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          '${widget.studentName}\'s Progress',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Monthly View'),
            Tab(text: 'Overall Progress'),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyView(),
          Center(child: Text('Overall Progress Coming Soon')),
        ],
      ),
    );
  }

Widget _buildMonthlyView() {
    return ListView(
      children: [
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
            eventLoader: (day) {
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
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
              _focusedDay = focusedDay;
              _loadMonthEvents(focusedDay);
            },
          ),
        ),

        // AI Insights Card
        if (!_isLoading) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) {
                    final monthEvents = _events.values.expand((e) => e).toList();
                    print('Building insights for ${monthEvents.length} events'); // Debug print

                    if (monthEvents.isEmpty) {
                      return Center(
                        child: Text(
                          'No evaluations recorded this month',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    final insights = InsightsGenerator.generateInsights(monthEvents);
                    print('Generated insights: ${insights.analysis}'); // Debug print

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.deepPurple),
                            SizedBox(width: 8),
                            Text(
                              'AI Insights',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          insights.analysis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        if (insights.recommendations.isNotEmpty) ...[
                          SizedBox(height: 24),
                          Text(
                            'Recommendations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          ...insights.recommendations.map((rec) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.arrow_right, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Expanded(child: Text(rec)),
                              ],
                            ),
                          )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMonthInsights() {
    final monthEvents = _events.values.expand((e) => e).toList();
    if (monthEvents.isEmpty) {
      return Center(
        child: Text(
          'No evaluations recorded this month',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Generate insights using InsightsGenerator
    final insights = InsightsGenerator.generateInsights(monthEvents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          insights.analysis,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.grey[800],
          ),
        ),
        if (insights.recommendations.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          ...insights.recommendations.map((recommendation) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right, 
                     color: Colors.deepPurple,
                     size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ],
    );
  }

  Widget _buildAssessmentBars() {
    final monthEvents = _events.values.expand((e) => e).toList();
    if (monthEvents.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        _buildAssessmentBar('Support'),
        SizedBox(height: 16),
        _buildAssessmentBar('Instruction'),
        SizedBox(height: 16),
        _buildAssessmentBar('Performance'),
      ],
    );
  }

  Widget _buildAssessmentBar(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.8, // Replace with actual calculation
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    final monthEvents = _events.values.expand((e) => e).toList();
    if (monthEvents.isEmpty) return SizedBox.shrink();

    // Generate insights using InsightsGenerator
    final insights = InsightsGenerator.generateInsights(monthEvents);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(insights.analysis),
          if (insights.recommendations.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...insights.recommendations.map((rec) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Expanded(child: Text(rec)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _showDayProgress(DateTime selectedDay, List<DailyProgress> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDailyProgressSheet(selectedDay, events),
    );
  }

  Widget _buildDailyProgressSheet(DateTime selectedDay, List<DailyProgress> events) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(selectedDay),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(),
          ...events.map((event) => _buildAssessmentCard(event)).toList(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(DailyProgress event) {
    return Card(
      margin: EdgeInsets.only(top: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Assessment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              event.skillName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            _buildLevelBox('Independence', event.supportLevel),
            SizedBox(height: 8),
            _buildLevelBox('Instruction', event.instructionLevel),
            SizedBox(height: 8),
            _buildLevelBox('Performance', event.performanceLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBox(String label, String level) {
    String displayText = level == '10' ? 'high' : level == '5' ? 'medium' : 'low';
    Color backgroundColor = level == '10' 
        ? Colors.green.withOpacity(0.1)
        : level == '5'
            ? Colors.orange.withOpacity(0.1)
            : Colors.red.withOpacity(0.1);
    Color textColor = level == '10'
        ? Colors.green
        : level == '5'
            ? Colors.orange
            : Colors.red;

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
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                displayText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}