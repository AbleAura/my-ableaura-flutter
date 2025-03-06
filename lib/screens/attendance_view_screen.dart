import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/attendance.dart';
import '../../services/student_service.dart';

class AttendanceViewScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const AttendanceViewScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<AttendanceViewScreen> createState() => _AttendanceViewScreenState();
}

class _AttendanceViewScreenState extends State<AttendanceViewScreen> {
  DateTime selectedMonth = DateTime.now();
  bool isLoading = false;
  List<AttendanceRecord> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _showMonthPicker() async {
    final currentYear = DateTime.now().year;
    int selectedYear = selectedMonth.year;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: isTablet ? 600 : double.infinity,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 28 : 20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * (isTablet ? 0.5 : 0.4),
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  // Year selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          size: isTablet ? 32 : 24,
                        ),
                        onPressed: selectedYear > 2020
                            ? () {
                                setModalState(() => selectedYear--);
                              }
                            : null,
                      ),
                      Text(
                        selectedYear.toString(),
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          size: isTablet ? 32 : 24,
                        ),
                        onPressed: selectedYear < currentYear
                            ? () {
                                setModalState(() => selectedYear++);
                              }
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  
                  // Month grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 6 : 4,
                        childAspectRatio: 1.5,
                        mainAxisSpacing: isTablet ? 12 : 8,
                        crossAxisSpacing: isTablet ? 12 : 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = DateTime(selectedYear, index + 1);
                        final isSelected = month.month == selectedMonth.month && 
                                        month.year == selectedMonth.year;
                        final isPastMonth = month.isBefore(DateTime.now());

                        return InkWell(
                          onTap: isPastMonth ? () {
                            setState(() {
                              selectedMonth = month;
                            });
                            Navigator.pop(context);
                            _loadAttendance();
                          } : null,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF303030) : null,
                              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF303030) : Colors.grey[300]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              DateFormat('MMM').format(month),
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: isSelected 
                                    ? Colors.white 
                                    : !isPastMonth
                                        ? Colors.grey[400]
                                        : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Done button for tablets
                  if (isTablet)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303030),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadAttendance() async {
    setState(() => isLoading = true);
    try {
      final records = await StudentService.getAttendanceRecords(
        widget.studentId,
        selectedMonth,
      );
      setState(() {
        attendanceRecords = records;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance History',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
      ),
      body: Column(
        children: [
          // Header with student name and month selector
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 20 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: isTablet ? 2 : 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.studentName,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: Icon(
                    Icons.calendar_today,
                    size: isTablet ? 24 : 20,
                  ),
                  label: Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                  onPressed: _showMonthPicker,
                ),
              ],
            ),
          ),

          // Attendance Records List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No attendance records found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 800 : screenWidth,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.all(isTablet ? 24 : 16),
                            itemCount: attendanceRecords.length,
                            itemBuilder: (context, index) {
                              final record = attendanceRecords[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: isTablet ? 16 : 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                ),
                                elevation: isTablet ? 2 : 1,
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 8 : 4),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: isTablet ? 20 : 16,
                                      vertical: isTablet ? 8 : 4,
                                    ),
                                    title: Text(
                                      record.enrollment.course.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 18 : 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: isTablet ? 6 : 4),
                                        Text(
                                          DateFormat('EEEE, MMMM d, y').format(record.date),
                                          style: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                          ),
                                        ),
                                        if (record.enrollment.course.level != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: isTablet ? 6 : 4),
                                            child: Text(
                                              'Level ${record.enrollment.course.level}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: isTablet ? 14 : 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? 16 : 12,
                                        vertical: isTablet ? 8 : 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: record.present
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                      ),
                                      child: Text(
                                        record.present ? 'Present' : 'Absent',
                                        style: TextStyle(
                                          color: record.present ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: isTablet ? 16 : 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}