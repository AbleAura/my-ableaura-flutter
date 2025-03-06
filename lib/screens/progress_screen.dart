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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F7FC), // Light purple background
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: isTablet ? 28 : 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${widget.studentName}\'s Progress',
          style: TextStyle(
            color: Colors.black,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Monthly View',
              height: isTablet ? 56 : 46,
              child: Text(
                'Monthly View', 
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            Tab(
              text: 'Overall Progress',
              height: isTablet ? 56 : 46,
              child: Text(
                'Overall Progress', 
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurple,
          indicatorWeight: isTablet ? 3 : 2,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyView(isTablet),
          Center(
            child: Text(
              'Overall Progress Coming Soon',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyView(bool isTablet) {
    return ListView(
      children: [
        // Calendar Card
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: Card(
              margin: EdgeInsets.all(isTablet ? 16 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              elevation: isTablet ? 2 : 1,
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 8),
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
                    // Adjust day sizes for tablet
                    cellMargin: EdgeInsets.all(isTablet ? 4 : 2),
                    cellPadding: EdgeInsets.all(isTablet ? 6 : 4),
                    defaultTextStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                    ),
                    selectedTextStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    outsideTextStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey,
                    ),
                    weekendTextStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.red[300],
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: isTablet ? 20 : 16, 
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left, 
                      size: isTablet ? 28 : 24,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right, 
                      size: isTablet ? 28 : 24,
                    ),
                    headerPadding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 8,
                    ),
                    headerMargin: EdgeInsets.only(
                      bottom: isTablet ? 16 : 8,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300],
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    final events = _getEventsForDay(selectedDay);
                    if (events.isNotEmpty) {
                      _showDayProgress(selectedDay, events, isTablet);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadMonthEvents(focusedDay);
                  },
                ),
              ),
            ),
          ),
        ),

        // AI Insights Card
        if (!_isLoading) ...[
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 16 : 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  elevation: isTablet ? 2 : 1,
                  child: Padding(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    child: Builder(
                      builder: (context) {
                        final monthEvents = _events.values.expand((e) => e).toList();

                        if (monthEvents.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: isTablet ? 40 : 24),
                              child: Text(
                                'No evaluations recorded this month',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                            ),
                          );
                        }

                        final insights = InsightsGenerator.generateInsights(monthEvents);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome, 
                                  color: Colors.deepPurple,
                                  size: isTablet ? 28 : 24,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  'AI Insights',
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 24 : 16),
                            Text(
                              insights.analysis,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                height: 1.5,
                              ),
                            ),
                            if (insights.recommendations.isNotEmpty) ...[
                              SizedBox(height: isTablet ? 32 : 24),
                              Text(
                                'Recommendations',
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: isTablet ? 16 : 12),
                              ...insights.recommendations.map((rec) => Padding(
                                padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.arrow_right, 
                                      color: Colors.deepPurple,
                                      size: isTablet ? 28 : 24,
                                    ),
                                    SizedBox(width: isTablet ? 12 : 8),
                                    Expanded(
                                      child: Text(
                                        rec,
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
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
            ),
          ),
        ],
      ],
    );
  }

  void _showDayProgress(DateTime selectedDay, List<DailyProgress> events, bool isTablet) {
    final bottomSheetHeight = MediaQuery.of(context).size.height * (isTablet ? 0.7 : 0.6);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 28 : 20),
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: isTablet ? 800 : double.infinity,
        maxHeight: bottomSheetHeight,
      ),
      builder: (context) => _buildDailyProgressSheet(selectedDay, events, isTablet),
    );
  }

  Widget _buildDailyProgressSheet(DateTime selectedDay, List<DailyProgress> events, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(selectedDay),
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: isTablet ? 28 : 24,
                ),
                padding: EdgeInsets.all(isTablet ? 8 : 4),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Divider(thickness: isTablet ? 2 : 1),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return _buildAssessmentCard(events[index], isTablet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(DailyProgress event, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(top: isTablet ? 24 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      elevation: isTablet ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Assessment',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              event.skillName,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildLevelBox('Independence', event.supportLevel, isTablet),
            SizedBox(height: isTablet ? 12 : 8),
            _buildLevelBox('Instruction', event.instructionLevel, isTablet),
            SizedBox(height: isTablet ? 12 : 8),
            _buildLevelBox('Performance', event.performanceLevel, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBox(String label, String level, bool isTablet) {
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
          width: isTablet ? 140 : 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 12 : 8,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(isTablet ? 8 : 4),
            ),
            child: Center(
              child: Text(
                displayText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}