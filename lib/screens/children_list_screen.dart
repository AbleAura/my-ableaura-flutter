import 'package:flutter/material.dart';
import 'package:my_ableaura/models/child.dart';
import 'package:my_ableaura/screens/id_card_screen.dart';
import '/services/student_service.dart';

class ChildrenListScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(int childId, String childName)? onChildSelected;

  const ChildrenListScreen({
    Key? key,
    required this.navigatorKey,
    this.onChildSelected,
  }) : super(key: key);

  @override
  _ChildrenListScreenState createState() => _ChildrenListScreenState();
}

class _ChildrenListScreenState extends State<ChildrenListScreen> {
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
      if (mounted && widget.onChildSelected == null) {  // Only for attendance flow
        if (response.data.childCount == 1) {
          final child = response.data.childDetails.first;
          _showIdCard(child);
        }
      }
    }).catchError((error) {
      print('Error loading children: $error');
    });
  }

  void _showIdCard(Child child) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IdCardScreen(
          childId: child.childId,
          childName: child.name,
          navigatorKey: widget.navigatorKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Child'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<ChildResponse>(
        future: _childrenResponse,
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
                    onPressed: _loadChildren,
                    child: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF303030),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data.childDetails.isEmpty) {
            return Center(
              child: Text('No children found'),
            );
          }

          final children = snapshot.data!.data.childDetails;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF303030),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    child.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(child.uniqueId),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (widget.onChildSelected != null) {
                      widget.onChildSelected!(child.childId, child.name);
                    } else {
                      _showIdCard(child);
                    }
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