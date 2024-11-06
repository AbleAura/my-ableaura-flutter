// lib/screens/progress/progress_view.dart

import 'package:flutter/material.dart';
import 'package:my_ableaura/screens/progress/components.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../models/progress_models.dart';
import '../../services/student_service.dart';
import 'progress_calendar_screen.dart';

class ProgressView extends StatelessWidget {
  final int childId;
  final String childName;

  const ProgressView({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${childName}\'s Progress'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Monthly View'),
              Tab(text: 'Overall Progress'),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            ProgressCalendarScreen(childId: childId, childName: childName),
            ProgressSummaryScreen(childId: childId, childName: childName),
          ],
        ),
      ),
    );
  }
}