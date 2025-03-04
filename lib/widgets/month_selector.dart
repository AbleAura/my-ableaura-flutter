// lib/widgets/month_selector.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onMonthSelected;
  final bool showYearFirst;
  
  const MonthSelector({
    Key? key,
    required this.initialDate,
    required this.onMonthSelected,
    this.firstDate,
    this.lastDate,
    this.showYearFirst = false,
  }) : super(key: key);

  @override
  _MonthSelectorState createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late DateTime _selectedDate;
  late PageController _yearController;
  bool _isSelectingYear = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _yearController = PageController(
      initialPage: _selectedDate.year - (widget.firstDate?.year ?? DateTime.now().year - 5),
    );
    
    // If showYearFirst is true, start with year selection
    _isSelectingYear = widget.showYearFirst;
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  List<DateTime> _getMonthsInYear(int year) {
    final List<DateTime> months = [];
    final firstDate = widget.firstDate;
    final lastDate = widget.lastDate;

    for (int i = 0; i < 12; i++) {
      final month = DateTime(year, i + 1);
      if (firstDate != null && month.isBefore(DateTime(firstDate.year, firstDate.month))) {
        continue;
      }
      if (lastDate != null && month.isAfter(DateTime(lastDate.year, lastDate.month))) {
        continue;
      }
      months.add(month);
    }
    return months;
  }

  List<int> _getAvailableYears() {
    final firstYear = widget.firstDate?.year ?? DateTime.now().year - 5;
    final lastYear = widget.lastDate?.year ?? DateTime.now().year + 5;
    return List.generate(lastYear - firstYear + 1, (index) => firstYear + index);
  }

  Widget _buildYearSelector() {
    final years = _getAvailableYears();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Select Year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _yearController,
            itemCount: years.length,
            itemBuilder: (context, index) {
              return GridView.builder(
                padding: EdgeInsets.all(16),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: years.length,
                itemBuilder: (context, idx) {
                  final year = years[idx];
                  final isSelected = year == _selectedDate.year;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime(year, _selectedDate.month);
                        _isSelectingYear = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final months = _getMonthsInYear(_selectedDate.year);
    final monthFormat = DateFormat('MMMM');
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with year selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  final previousYear = _selectedDate.year - 1;
                  final firstYear = widget.firstDate?.year ?? DateTime.now().year - 5;
                  if (previousYear >= firstYear) {
                    setState(() {
                      _selectedDate = DateTime(previousYear, _selectedDate.month);
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSelectingYear = true;
                  });
                },
                child: Text(
                  _selectedDate.year.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  final nextYear = _selectedDate.year + 1;
                  final lastYear = widget.lastDate?.year ?? DateTime.now().year + 5;
                  if (nextYear <= lastYear) {
                    setState(() {
                      _selectedDate = DateTime(nextYear, _selectedDate.month);
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Divider(),
        // Month grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month.year == _selectedDate.year && 
                                month.month == _selectedDate.month;
              final isCurrentMonth = month.year == DateTime.now().year && 
                                   month.month == DateTime.now().month;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = month;
                  });
                  widget.onMonthSelected(month);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : isCurrentMonth 
                            ? Theme.of(context).primaryColorLight.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : isCurrentMonth
                            ? Theme.of(context).primaryColorLight
                            : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      monthFormat.format(month),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected || isCurrentMonth 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          // Header with handle and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draggable handle
                Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      _isSelectingYear ? 'Select Year' : 'Select Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Balanced spacing
                    SizedBox(width: 48),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Content based on selection mode
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _isSelectingYear
                  ? _buildYearSelector()
                  : _buildMonthSelector(),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper method to show the month selector
Future<void> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required Function(DateTime) onMonthSelected,
  DateTime? firstDate,
  DateTime? lastDate,
  bool showYearFirst = false,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => MonthSelector(
      initialDate: initialDate,
      onMonthSelected: onMonthSelected,
      firstDate: firstDate,
      lastDate: lastDate,
      showYearFirst: showYearFirst,
    ),
  );
}