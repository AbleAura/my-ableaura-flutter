import 'package:flutter/material.dart';
import '/services/student_service.dart';

class MarkAttendanceScreen extends StatefulWidget {
  final int studentId;
  final int sessionId;
  final int enrollmentId;
  final String childName;
  final String sessionName;

  const MarkAttendanceScreen({
    Key? key,
    required this.studentId,
    required this.sessionId,
    required this.enrollmentId,
    required this.childName,
    required this.sessionName, required String date,
  }) : super(key: key);

  @override
  _MarkAttendanceScreenState createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _markAttendance() async {
    print('Starting attendance marking...'); // Debug print
    print('Student ID: ${widget.studentId}'); // Debug print
    print('Session ID: ${widget.sessionId}'); // Debug print
    print('Enrollment ID: ${widget.enrollmentId}'); // Debug print

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await StudentService.markAttendance(
        sessionId: widget.sessionId,
        enrollmentId: widget.enrollmentId,
        studentId: widget.studentId,
      );

      print('Attendance marked successfully'); // Debug print
      print('Response: $response'); // Debug print

      // Show success dialog
      if (mounted) {
        _showAttendanceDialog(response);
      }
    } catch (e) {
      print('Error marking attendance: $e'); // Debug print
      setState(() {
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAttendanceDialog(AttendanceResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(response.profilePicture),
              ),
              const SizedBox(height: 16),
              Text(
                response.studentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                response.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go to home screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
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
                      'Session: ${widget.sessionName}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Debug information
                    const Divider(),
                    const Text(
                      'Debug Info:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Student ID: ${widget.studentId}\n'
                      'Session ID: ${widget.sessionId}\n'
                      'Enrollment ID: ${widget.enrollmentId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _markAttendance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303030),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Mark Present',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}