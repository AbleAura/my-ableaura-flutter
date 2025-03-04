// lib/screens/progress/progress_view.dart

import 'package:flutter/material.dart';
import 'package:my_ableaura/screens/progress/components.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';
import 'progress_calendar_screen.dart';

class ProgressView extends StatefulWidget {
  final int childId;
  final String childName;

  const ProgressView({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  _ProgressViewState createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  late DateTime _selectedMonth;
  late List<int> _availableYears;
  late Map<int, List<int>> _availableMonths;
  int _currentYearIndex = 0;
  bool _isLoadingMonths = true;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _setupAvailableMonths();
    _loadAvailableMonths();
  }
  
  void _setupAvailableMonths() {
    // Set up years - include several previous years for flexibility
    final currentYear = DateTime.now().year;
    _availableYears = [currentYear - 3, currentYear - 2, currentYear - 1, currentYear];
    _currentYearIndex = 3;  // Default to current year
    
    // Initially set up empty months - will be populated by API call
    _availableMonths = {};
    for (var year in _availableYears) {
      _availableMonths[year] = [];
    }
  }
  
  Future<void> _loadAvailableMonths() async {
    setState(() => _isLoadingMonths = true);
    try {
      // In real implementation, fetch from API
      // For now, using mock data
      final availableMonths = await StudentService.getAvailableProgressMonthsMock(widget.childId);
      
      // Organize months by year
      final monthsByYear = <int, List<int>>{};
      for (var month in availableMonths) {
        final year = month.year;
        final monthNum = month.month;
        
        if (!monthsByYear.containsKey(year)) {
          monthsByYear[year] = [];
        }
        
        if (!monthsByYear[year]!.contains(monthNum)) {
          monthsByYear[year]!.add(monthNum);
        }
      }
      
      if (mounted) {
        setState(() {
          _availableMonths = monthsByYear;
          _isLoadingMonths = false;
          
          // Update available years based on data
          if (monthsByYear.keys.isNotEmpty) {
            final dataYears = monthsByYear.keys.toList()..sort();
            // Merge with predefined years to ensure we have a good range
            final allYears = {..._availableYears, ...dataYears}.toList()..sort();
            _availableYears = allYears;
            _currentYearIndex = _availableYears.indexOf(DateTime.now().year);
            if (_currentYearIndex < 0) _currentYearIndex = _availableYears.length - 1;
          }
        });
      }
    } catch (e) {
      print('Error loading available months: $e');
      if (mounted) {
        setState(() => _isLoadingMonths = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _selectMonth(int month) {
    final year = _availableYears[_currentYearIndex];
    final newDate = DateTime(year, month);
    setState(() {
      _selectedMonth = newDate;
    });
  }
  
  void _changeYear(int direction) {
    final newIndex = _currentYearIndex + direction;
    if (newIndex >= 0 && newIndex < _availableYears.length) {
      setState(() {
        _currentYearIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = _availableYears[_currentYearIndex];
    final months = _availableMonths[currentYear] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.childName}\'s Progress',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Year and month selector
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // Year selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: _currentYearIndex > 0 
                            ? () => _changeYear(-1) 
                            : null,
                        color: _currentYearIndex > 0 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300],
                      ),
                      Text(
                        currentYear.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: _currentYearIndex < _availableYears.length - 1 
                            ? () => _changeYear(1) 
                            : null,
                        color: _currentYearIndex < _availableYears.length - 1 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                
                // Month selector
                _isLoadingMonths
                    ? Container(
                        height: 64,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            final month = index + 1;
                            final date = DateTime(currentYear, month);
                            final monthName = DateFormat('MMM').format(date);
                            final isAvailable = months.contains(month);
                            final isSelected = _selectedMonth.year == currentYear && 
                                             _selectedMonth.month == month;
                            
                            return Container(
                              width: 60,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: isAvailable ? () => _selectMonth(month) : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : isAvailable
                                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                                            : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        monthName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : isAvailable
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.grey[500],
                                        ),
                                      ),
                                      if (isAvailable && !isSelected)
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          
          // Calendar screen
          Expanded(
            child: ProgressCalendarScreen(
              childId: widget.childId,
              childName: widget.childName,
              selectedMonth: _selectedMonth,
            ),
          ),
        ],
      ),
    );
  }
}