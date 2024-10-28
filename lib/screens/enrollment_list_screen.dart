import 'package:flutter/material.dart';
import '/models/enrollment.dart';
import '/services/student_service.dart';
import 'session_selection_screen.dart';

class EnrollmentListScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final String uniqueId;

  EnrollmentListScreen({
    required this.childId,
    required this.childName,
    required this.uniqueId,
  });

  @override
  _EnrollmentListScreenState createState() => _EnrollmentListScreenState();
}

class _EnrollmentListScreenState extends State<EnrollmentListScreen> {
  late Future<List<Enrollment>> _enrollmentsList;

  @override
  void initState() {
    super.initState();
    _enrollmentsList = StudentService.getChildEnrollments(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Branch'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Enrollment>>(
        future: _enrollmentsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _enrollmentsList = StudentService.getChildEnrollments(widget.childId);
                      });
                    },
                    child: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF303030),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No enrollments found for ${widget.childName}'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final enrollment = snapshot.data![index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    enrollment.franchiseName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Center: ${enrollment.centerName}'),
                      Text('Course: ${enrollment.courseName}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    print('Navigating with franchiseId: ${enrollment.franchiseId}'); // Debug print
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionSelectionScreen(
                          childId: widget.childId,
                          childName: widget.childName,
                          franchiseId: enrollment.franchiseId, // Make sure this is being passed
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
    );
  }
}