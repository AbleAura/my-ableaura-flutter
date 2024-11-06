import 'package:flutter/material.dart';
import '/services/student_service.dart';
import '../models/session.dart';
import 'mark_attendance_screen.dart';

class SessionSelectionScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final int franchiseId;
  final GlobalKey<NavigatorState> navigatorKey;  // Add this

  const SessionSelectionScreen({
     Key? key,
    required this.childId,
    required this.childName,
    required this.franchiseId,
     required this.navigatorKey,  // Add this
  }): super(key: key);

  @override
  _SessionSelectionScreenState createState() => _SessionSelectionScreenState();
}

class _SessionSelectionScreenState extends State<SessionSelectionScreen> {
  late Future<List<Session>> _sessions;

  @override
  void initState() {
    super.initState();
    // Updated this line to pass required parameters
    _sessions = StudentService.getEnrolledSessions(
      franchiseId: widget.franchiseId,
      studentId: widget.childId,  // childId is actually the studentId
    );
  }

  void _refreshSessions() {
    setState(() {
      _sessions = StudentService.getEnrolledSessions(
        franchiseId: widget.franchiseId,
        studentId: widget.childId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Session'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.childName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a session to mark attendance',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _sessions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshSessions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303030),
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No sessions available'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final session = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          session.sessionName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('${session.startTime} - ${session.endTime}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
    builder: (context) => MarkAttendanceScreen(
      studentId: widget.childId,
      sessionId: session.sessionId,
      enrollmentId: session.enrollmentId,
      childName: widget.childName,
      sessionName: session.sessionName,
      navigatorKey: widget.navigatorKey,  // Pass the navigatorKey
      date: DateTime.now().toString().split(' ')[0],
    ),
  ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}