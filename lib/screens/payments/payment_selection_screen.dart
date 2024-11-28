import 'package:flutter/material.dart';
import '/models/child.dart';
import 'payment_list_screen.dart';
import '../../services/student_service.dart';

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
  late Future<ChildResponse> _childrenResponse;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  void _loadChildren() {
    setState(() {
      _childrenResponse = StudentService.getChildrenList();
    });

    _childrenResponse.then((response) {
      if (mounted && response.data.childCount == 1 && response.data.childDetails.isNotEmpty) {
        final child = response.data.childDetails.first;
        // Direct navigation to PaymentListScreen for single child
        _navigateToPaymentList(child);
      }
    }).catchError((error) {
      print('Error loading children: $error');
    });
  }

  void _navigateToPaymentList(Child child) {
    // Using pushReplacement for single child to avoid back navigation
    if (mounted) {
      final route = MaterialPageRoute(
        builder: (context) => PaymentListScreen(
          studentId: child.childId,
          studentName: child.name,
        ),
      );

      if (widget.navigatorKey.currentContext != null) {
        // Use pushReplacement for single child case
        if (widget.navigatorKey.currentState?.canPop() ?? false) {
          Navigator.of(context).pushReplacement(route);
        } else {
          Navigator.of(context).push(route);
        }
      }
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
      body: FutureBuilder<ChildResponse>(
        future: _childrenResponse,
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
                    onPressed: _loadChildren,
                    child: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF303030),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data.childDetails.isEmpty) {
            return const Center(
              child: Text('No children found'),
            );
          }

          // Only show the list if there's more than one child
          if (snapshot.data!.data.childCount > 1) {
            final children = snapshot.data!.data.childDetails;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF303030),
                      child: Text(
                        child.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      child.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(child.uniqueId),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _navigateToPaymentList(child),
                  ),
                );
              },
            );
          }

          // Show loading for single child case
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}