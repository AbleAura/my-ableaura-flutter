// lib/screens/progress/progress_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';

class ProgressCalendarScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final DateTime? selectedMonth;

  const ProgressCalendarScreen({
    Key? key,
    required this.childId,
    required this.childName,
    this.selectedMonth,
  }) : super(key: key);

  @override
  _ProgressCalendarScreenState createState() => _ProgressCalendarScreenState();
}

class _ProgressCalendarScreenState extends State<ProgressCalendarScreen> {
  late DateTime _currentMonth;
  Map<DateTime, List<DailyProgress>> _events = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedMonth ?? DateTime.now();
    _loadMonthEvents(_currentMonth);
  }
  
  @override
  void didUpdateWidget(ProgressCalendarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // React to changes in the selected month from parent
    if (widget.selectedMonth != null && 
        (oldWidget.selectedMonth == null || 
         widget.selectedMonth!.month != oldWidget.selectedMonth!.month ||
         widget.selectedMonth!.year != oldWidget.selectedMonth!.year)) {
      _currentMonth = widget.selectedMonth!;
      _loadMonthEvents(_currentMonth);
    }
  }

  Future<void> _loadMonthEvents(DateTime month) async {
    setState(() => _isLoading = true);
    try {
      final progressList = await StudentService.getMonthlyProgress(
        widget.childId,
        month,
      );
      
      if (mounted) {
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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load progress data: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthEvents = _events.values.expand((e) => e).toList();
    
    return _isLoading 
      ? Center(child: CircularProgressIndicator())
      : monthEvents.isEmpty
        ? _buildEmptyState()
        : SingleChildScrollView(
            child: _buildMonthSummary(monthEvents),
          );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No progress data for ${DateFormat('MMMM yyyy').format(_currentMonth)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthSummary(List<DailyProgress> events) {
    // Group events by day
    final days = events.fold<Map<DateTime, List<DailyProgress>>>(
      {},
      (map, event) {
        final day = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        if (!map.containsKey(day)) {
          map[day] = [];
        }
        map[day]!.add(event);
        return map;
      },
    );
    
    // Sort days
    final sortedDays = days.keys.toList()..sort();
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month overview card
          Card(
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
                      Expanded(
                        child: Text(
                          '${DateFormat('MMMM yyyy').format(_currentMonth)} Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                        '${events.length} evaluation sessions on ${sortedDays.length} days',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Monthly progress trend visualization
                  _buildMonthlyTrendVisualization(events, sortedDays),
                  SizedBox(height: 20),
                  // Summary by skill
                  _buildSkillsSummary(events),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Daily progress cards
          ...sortedDays.map((day) => _buildDayCard(day, days[day]!)).toList(),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyTrendVisualization(List<DailyProgress> allEvents, List<DateTime> sortedDays) {
    // Calculate average scores per day
    final dailyScores = <DateTime, Map<String, double>>{};
    
    for (var day in sortedDays) {
      final dayEvents = _events[day] ?? [];
      if (dayEvents.isEmpty) continue;
      
      double supportSum = 0;
      double instructionSum = 0;
      double performanceSum = 0;
      
      for (var event in dayEvents) {
        supportSum += _getLevelValue(event.supportLevel);
        instructionSum += _getLevelValue(event.instructionLevel);
        performanceSum += _getLevelValue(event.performanceLevel);
      }
      
      dailyScores[day] = {
        'support': supportSum / dayEvents.length,
        'instruction': instructionSum / dayEvents.length,
        'performance': performanceSum / dayEvents.length,
      };
    }
    
    if (dailyScores.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Progress Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 180,
          child: _buildCustomLineChart(dailyScores),
        ),
      ],
    );
  }
  
  Widget _buildCustomLineChart(Map<DateTime, Map<String, double>> dailyScores) {
    // Convert to sorted list for easier rendering
    final sortedData = dailyScores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // Chart legends
    final legendItems = [
      _buildLegendItem('Support', Colors.blue),
      _buildLegendItem('Instruction', Colors.amber),
      _buildLegendItem('Performance', Colors.green),
    ];
    
    return Column(
      children: [
        // Legends row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...legendItems,
          ],
        ),
        SizedBox(height: 8),
        // Chart
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.only(top: 16, right: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = constraints.maxWidth;
                  final chartHeight = constraints.maxHeight - 24; // Space for date labels
                  
                  // Calculate x positions
                  final pointWidth = sortedData.length > 1 
                      ? chartWidth / (sortedData.length - 1)
                      : chartWidth;
                  
                  // Draw lines for each metric
                  return Stack(
                    children: [
                      // Draw background grid lines
                      _buildGridLines(chartHeight),
                      
                      // Support line
                      _buildMetricLine(
                        sortedData, 
                        'support', 
                        Colors.blue, 
                        pointWidth, 
                        chartHeight
                      ),
                      
                      // Instruction line
                      _buildMetricLine(
                        sortedData, 
                        'instruction', 
                        Colors.amber, 
                        pointWidth, 
                        chartHeight
                      ),
                      
                      // Performance line
                      _buildMetricLine(
                        sortedData, 
                        'performance', 
                        Colors.green, 
                        pointWidth, 
                        chartHeight
                      ),
                      
                      // Date labels at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _buildDateLabels(sortedData, pointWidth),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGridLines(double height) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Horizontal grid lines (25%, 50%, 75%, 100%)
                  ...List.generate(4, (index) {
                    final y = height * (1 - ((index + 1) * 0.25));
                    return Positioned(
                      top: y,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateLabels(List<MapEntry<DateTime, Map<String, double>>> sortedData, double pointWidth) {
    if (sortedData.length <= 5) {
      // If few points, show all dates
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: sortedData.map((entry) {
          return SizedBox(
            width: 40,
            child: Text(
              DateFormat('MM/dd').format(entry.key),
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      );
    } else {
      // Otherwise, show only first, middle, and last dates
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              DateFormat('MM/dd').format(sortedData.first.key),
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              DateFormat('MM/dd').format(sortedData[sortedData.length ~/ 2].key),
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              DateFormat('MM/dd').format(sortedData.last.key),
              style: TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
  }
  
  Widget _buildMetricLine(
    List<MapEntry<DateTime, Map<String, double>>> sortedData,
    String metric,
    Color color,
    double pointWidth,
    double chartHeight,
  ) {
    if (sortedData.length < 2) {
      return SizedBox.shrink();
    }
    
    return CustomPaint(
      size: Size.infinite,
      painter: LinePainter(
        points: sortedData.asMap().entries.map((entry) {
          final idx = entry.key;
          final data = entry.value;
          // Convert to point coordinates
          final x = idx * pointWidth;
          // Normalize value to chart height (max value is 10)
          final y = chartHeight * (1 - (data.value[metric] ?? 0) / 10);
          return Offset(x, y);
        }).toList(),
        color: color,
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 4,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayCard(DateTime day, List<DailyProgress> events) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(day),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Daily visualization
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildDailyVisual(events),
          ),
          
          // Progress entries
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: events.map((event) => 
                _buildProgressCard(event)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
Widget _buildDailyVisual(List<DailyProgress> events) {
  // Group events by main skill, then sub-skills
  final mainSkillGroups = <String, Map<String, List<DailyProgress>>>{};
  
  for (var event in events) {
    if (!mainSkillGroups.containsKey(event.skillName)) {
      mainSkillGroups[event.skillName] = {};
    }
    
    final subSkillName = event.subSkillName.isNotEmpty 
        ? event.subSkillName 
        : 'General';
        
    if (!mainSkillGroups[event.skillName]!.containsKey(subSkillName)) {
      mainSkillGroups[event.skillName]![subSkillName] = [];
    }
    
    mainSkillGroups[event.skillName]![subSkillName]!.add(event);
  }
  
  if (mainSkillGroups.isEmpty) return SizedBox.shrink();
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Day Overview',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      
      // Individual skill groups
      ...mainSkillGroups.entries.map((mainEntry) {
        final mainSkill = mainEntry.key;
        final subSkills = mainEntry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main skill heading
              Text(
                mainSkill,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              SizedBox(height: 12),
              
              // Sub-skills
              ...subSkills.entries.map((subEntry) {
                final subSkill = subEntry.key;
                final subSkillEvents = subEntry.value;
                
                // Get the most recent event for this sub-skill
                final recentEvent = subSkillEvents.isNotEmpty 
                    ? subSkillEvents.reduce((a, b) => 
                        a.evaluationTime.isAfter(b.evaluationTime) ? a : b)
                    : null;
                    
                if (recentEvent == null) return SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub-skill name
                      Text(
                        subSkill,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      // Support level indicator
                      _buildHorizontalLevelIndicator('Support', recentEvent.supportLevel, Colors.blue),
                      SizedBox(height: 12),
                      
                      // Instruction level indicator
                      _buildHorizontalLevelIndicator('Instruction', recentEvent.instructionLevel, Colors.amber),
                      SizedBox(height: 12),
                      
                      // Performance level indicator
                      _buildHorizontalLevelIndicator('Performance', recentEvent.performanceLevel, Colors.green),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    ],
  );
}

Widget _buildHorizontalLevelIndicator(String label, String level, Color color) {
  // Calculate width based on level
  final width = level.toLowerCase() == 'high' ? 0.75 : 
               level.toLowerCase() == 'medium' ? 0.5 : 0.25;
               
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      Container(
        height: 10,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: FractionallySizedBox(
          widthFactor: width,
          heightFactor: 1.0,
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    ],
  );
}

// Helper method to build a single bar in the chart
Widget _buildBarChartColumn(String label, double value, Color color) {
  // Calculate height percentage (0 to 1 scale)
  final heightPercentage = value / 10.0;
  
  return Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // We'll show the level text instead of numeric value
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            _getLevelText(value),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 4),
        // The actual bar
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: 40 * heightPercentage + 5, // Ensure at least 5px height
          width: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ),
        // Label below the bar
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}

// Helper method to get text representation of level
String _getLevelText(double value) {
  if (value < 4) return 'low';
  if (value < 7) return 'medium';
  return 'high';
}

// Add a method to build the main skills chart
Widget _buildMainSkillsChart(Map<String, Map<String, List<DailyProgress>>> mainSkillGroups) {
  // Calculate averages for each main skill
  final mainSkillAverages = <String, Map<String, double>>{};
  
  mainSkillGroups.forEach((mainSkill, subSkills) {
    // Flatten all events for this main skill
    final allEvents = subSkills.values.expand((events) => events).toList();
    
    final supportAvg = _calculateAverage(allEvents, 'support');
    final instructionAvg = _calculateAverage(allEvents, 'instruction');
    final performanceAvg = _calculateAverage(allEvents, 'performance');
    
    mainSkillAverages[mainSkill] = {
      'support': supportAvg,
      'instruction': instructionAvg,
      'performance': performanceAvg,
    };
  });
  
  // Build horizontal bar chart showing all main skills
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'Skills Overview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      ...mainSkillAverages.entries.map((entry) {
        final skill = entry.key;
        final averages = entry.value;
        
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Container(
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: (averages['support']! * 10).round(),
                      child: Container(color: Colors.blue),
                    ),
                    Expanded(
                      flex: (averages['instruction']! * 10).round(),
                      child: Container(color: Colors.amber),
                    ),
                    Expanded(
                      flex: (averages['performance']! * 10).round(),
                      child: Container(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      
      // Legend
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Support', Colors.blue),
            SizedBox(width: 16),
            _buildLegendItem('Instruction', Colors.amber),
            SizedBox(width: 16),
            _buildLegendItem('Performance', Colors.green),
          ],
        ),
      ),
    ],
  );
}
  
  Map<String, List<DailyProgress>> _groupBySkill(List<DailyProgress> events) {
    return events.fold<Map<String, List<DailyProgress>>>(
      {},
      (map, event) {
        if (!map.containsKey(event.skillName)) {
          map[event.skillName] = [];
        }
        map[event.skillName]!.add(event);
        return map;
      },
    );
  }
  
  double _calculateAverage(List<DailyProgress> events, String metric) {
    if (events.isEmpty) return 0;
    
    double sum = 0;
    for (var event in events) {
      switch (metric) {
        case 'support':
          sum += _getLevelValue(event.supportLevel);
          break;
        case 'instruction':
          sum += _getLevelValue(event.instructionLevel);
          break;
        case 'performance':
          sum += _getLevelValue(event.performanceLevel);
          break;
      }
    }
    return sum / events.length;
  }
  
  Widget _buildLevelBarSimple(String label, double value, Color color) {
    final percentage = value / 10; // Convert to 0-1 range
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage,
            heightFactor: 1.0,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProgressCard(DailyProgress progress) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.skillName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (progress.subSkillName.isNotEmpty) 
                        Text(
                          progress.subSkillName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(progress.evaluationTime),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildLevelBox('Support', progress.supportLevel),
                SizedBox(width: 8),
                _buildLevelBox('Instruction', progress.instructionLevel),
                SizedBox(width: 8),
                _buildLevelBox('Performance', progress.performanceLevel),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelBox(String label, String level) {
    final Color color = _getLevelColor(_getLevelValue(level));
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                level,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSummary(List<DailyProgress> events) {
    // Group events by skill
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

    if (skillGroups.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...skillGroups.entries.map((entry) => 
          _buildSkillProgressBar(entry.key, entry.value)
        ).toList(),
      ],
    );
  }

  Widget _buildSkillProgressBar(String skillName, List<DailyProgress> skillEvents) {
    // Calculate average levels
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
          SizedBox(height: 8),
          _buildProgressIndicator('Support', avgSupport),
          SizedBox(height: 4),
          _buildProgressIndicator('Instruction', avgInstruction),
          SizedBox(height: 4),
          _buildProgressIndicator('Performance', avgPerformance),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double value) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: value / 10, // Assuming max is 10
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getLevelColor(value)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
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

// Custom painter for line charts
class LinePainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double lineWidth;

  LinePainter({
    required this.points,
    required this.color,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw dots at each point
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.points != points || 
           oldDelegate.color != color ||
           oldDelegate.lineWidth != lineWidth;
  }
}