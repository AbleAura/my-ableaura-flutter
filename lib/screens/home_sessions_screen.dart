import 'package:flutter/material.dart';
import '../../models/home_session.dart';
import '../../services/student_service.dart';
import 'package:intl/intl.dart';

import 'session_feedback_screen.dart';

class HomeSessionsScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const HomeSessionsScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<HomeSessionsScreen> createState() => _HomeSessionsScreenState();
}

class _HomeSessionsScreenState extends State<HomeSessionsScreen> {
  bool _isLoading = true;
  String? _error;
  List<HomeSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await StudentService.getHomeSessions(widget.studentId);
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'not started':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSessionCard(HomeSession session, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      elevation: isTablet ? 2 : 1,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session.listing,
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                      ),
                      child: Text(
                        session.status,
                        style: TextStyle(
                          color: _getStatusColor(session.status),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: isTablet ? 24 : 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(session.date)}',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                // Coach Status
                Row(
                  children: [
                    Icon(
                      session.coach != null 
                          ? Icons.verified_user_outlined 
                          : Icons.pending_outlined,
                      size: isTablet ? 24 : 20,
                      color: session.coach != null ? Colors.green : Colors.orange,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      'Coach Status: ${session.coach != null ? "Assigned" : "Not Assigned"}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: session.coach != null ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
                if (session.coach != null) ...[
                  SizedBox(height: isTablet ? 12 : 8),
                  // Coach Name
                  Row(
                    children: [
                      Icon(
                        Icons.sports,
                        size: isTablet ? 24 : 20,
                        color: Colors.blue,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Text(
                        'Coach Name: ${session.coach}',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: isTablet ? 16 : 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: isTablet ? 24 : 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      '${session.fromTime} - ${session.toTime}',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (session.status.toLowerCase() == 'completed' && !session.hasFeedback)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: isTablet ? 2 : 1),
                ),
              ),
              child: SizedBox(
                height: isTablet ? 56 : 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 12 : 8,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionFeedbackScreen(
                          sessionId: session.id,
                          coachName: session.coach ?? 'Unknown Coach',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Share Feedback',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.studentName}\'s Home Sessions',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                        child: Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      SizedBox(
                        height: isTablet ? 56 : 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303030),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 32 : 24,
                              vertical: isTablet ? 12 : 8,
                            ),
                          ),
                          onPressed: _loadSessions,
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports,
                            size: isTablet ? 80 : 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          Text(
                            'No home sessions scheduled for today',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 20 : 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSessions,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 800 : double.infinity,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.all(isTablet ? 24 : 16),
                            itemCount: _sessions.length,
                            itemBuilder: (context, index) => _buildSessionCard(_sessions[index], isTablet),
                          ),
                        ),
                      ),
                    ),
    );
  }
}