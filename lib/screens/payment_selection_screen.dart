import 'package:flutter/material.dart';
import 'package:my_ableaura/models/child.dart';
import 'package:my_ableaura/screens/payment_screen.dart';
import '../services/student_service.dart';

class PaymentSelectionScreen extends StatefulWidget {
    final GlobalKey<NavigatorState> navigatorKey;
    const PaymentSelectionScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);
  
  @override
  _PaymentSelectionScreenState createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  late Future<List<Child>> _childrenList;

  @override
  void initState() {
    super.initState();
    _childrenList = StudentService.getChildrenList();
  }

  Future<void> _showEnrollments(Child child) async {
    try {
      final enrollments = await StudentService.getChildEnrollments(child.childId);
      if (!mounted) return;

      if (enrollments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No enrollments found for this child')),
        );
        return;
      }

      // Show enrollments in bottom sheet
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Enrollment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: enrollments.length,
                  itemBuilder: (context, index) {
                    final enrollment = enrollments[index];
                    return ListTile(
                      title: Text(enrollment.franchiseName),
                      subtitle: Text(enrollment.centerName),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentsScreen(
                              enrollmentId: enrollment.id,
                              studentName: child.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Child'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Child>>(
        future: _childrenList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No children found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final child = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(child.name),
                  subtitle: Text(child.uniqueId),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showEnrollments(child),
                ),
              );
            },
          );
        },
      ),
    );
  }
}