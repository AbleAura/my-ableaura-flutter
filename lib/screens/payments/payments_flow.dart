import 'package:flutter/material.dart';
import '../../models/child.dart';
import '../../services/student_service.dart';
import 'payments_menu_screen.dart';

class PaymentsFlow extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const PaymentsFlow({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<PaymentsFlow> createState() => _PaymentsFlowState();
}

class _PaymentsFlowState extends State<PaymentsFlow> {
  bool _isLoading = true;
  String? _error;
  List<Child> _children = [];
  bool _shouldShowList = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

Future<void> _loadAndNavigateEnrollments(Child child) async {
  try {
    final enrollments = await StudentService.getChildEnrollments(child.childId);

    if (!mounted) return;

    // Always navigate to PaymentsMenuScreen with studentId
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentsMenuScreen(
          studentId: child.childId,  // Using childId instead of enrollmentId
          studentName: child.name,
          navigatorKey: widget.navigatorKey,
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading enrollments: $e')),
    );
  }
}
  Future<void> _loadChildren() async {
    try {
      final response = await StudentService.getChildrenList();
      
      if (!mounted) return;

      final responseData = response.data as Map<String, dynamic>;
      final childCount = responseData['child_count'] as int;
      final childDetails = responseData['child_details'] as List<dynamic>;
      
      debugPrint('Child count from API: $childCount');
      
      final List<Child> children = childDetails
          .map((child) => Child.fromJson(child))
          .toList();

      // If there's only one child, navigate immediately
      if (childCount == 1) {
        debugPrint('Single child detected, navigating directly');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentsMenuScreen(
              studentId: children[0].childId,
              studentName: children[0].name,
              navigatorKey: widget.navigatorKey,
            ),
          ),
        );
        return; // Exit early, don't update state
      }

      // Only update state if we have multiple children
      setState(() {
        _children = children;
        _isLoading = false;
        _shouldShowList = true;
      });

    } catch (e) {
      debugPrint('Error loading children: $e');
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadChildren();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303030),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_shouldShowList) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Child'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentsMenuScreen(
                      studentId: child.childId,
                      studentName: child.name,
                      navigatorKey: widget.navigatorKey,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}