// lib/screens/progress/progress_view.dart

import 'package:flutter/material.dart';
import 'progress_list_screen.dart';
import 'overall_progress_screen.dart';

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
            tabs: const [
              Tab(text: 'Monthly View'),
              Tab(text: 'Overall Progress'),
            ],
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.deepPurple,
            indicatorWeight: 3,
          ),
        ),
        body: TabBarView(
          children: [
            // Monthly View Tab
            ProgressListScreen(
              childId: childId,
              childName: childName,
            ),
            // Overall Progress Tab with AI Insights
            OverallProgressScreen(
              childId: childId,
              childName: childName,
            ),
          ],
        ),
      ),
    );
  }
}