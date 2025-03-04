// lib/widgets/month_selection_indicator.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelectionIndicator extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onTap;
  final bool isLoading;
  final String? tooltipMessage;

  const MonthSelectionIndicator({
    Key? key,
    required this.currentMonth,
    required this.onTap,
    this.isLoading = false,
    this.tooltipMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage ?? 'Select a different month',
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month and year display
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      DateFormat('MMMM yyyy').format(currentMonth),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                // Loading indicator or dropdown icon
                isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade700,
                          size: 18,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper method to determine if a month has data
class MonthDataIndicator extends StatelessWidget {
  final List<DateTime> monthsWithData;
  final DateTime currentMonth;
  final Function(DateTime) onMonthSelected;
  
  const MonthDataIndicator({
    Key? key,
    required this.monthsWithData,
    required this.currentMonth,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentYear = currentMonth.year;
    final monthsInCurrentYear = monthsWithData
        .where((date) => date.year == currentYear)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Available Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final date = DateTime(currentYear, month);
              final monthAbbr = DateFormat('MMM').format(date);
              final hasData = monthsWithData.any((d) => 
                d.year == date.year && d.month == date.month);
              final isCurrentSelected = currentMonth.month == month && 
                                      currentMonth.year == currentYear;
              
              return GestureDetector(
                onTap: hasData ? () => onMonthSelected(date) : null,
                child: Container(
                  width: 60,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCurrentSelected
                        ? Theme.of(context).primaryColor
                        : hasData 
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentSelected
                          ? Theme.of(context).primaryColor
                          : hasData
                              ? Theme.of(context).primaryColorLight
                              : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      monthAbbr,
                      style: TextStyle(
                        color: isCurrentSelected
                            ? Colors.white
                            : hasData
                                ? Theme.of(context).primaryColor
                                : Colors.grey[500],
                        fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Year selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Year: $currentYear',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 16),
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                    color: Colors.grey[700],
                    onPressed: () {
                      final previousYear = DateTime(currentYear - 1, currentMonth.month);
                      onMonthSelected(previousYear);
                    },
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 16),
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                    color: Colors.grey[700],
                    onPressed: () {
                      final nextYear = DateTime(currentYear + 1, currentMonth.month);
                      // Only allow navigating up to current year
                      if (nextYear.year <= DateTime.now().year) {
                        onMonthSelected(nextYear);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}