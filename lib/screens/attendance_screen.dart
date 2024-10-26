import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/user_provider.dart';
import '/services/api_service.dart';
import '/widgets/neumorphic_box.dart';

class AttendanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final children = userProvider.children;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
      ),
      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: UberStyleBox(
              child: ListTile(
                title: Text(children[index], style: TextStyle(color: Colors.white)),
                trailing: Switch(
                  value: false,
                  onChanged: (value) async {
                    try {
                      await ApiService.markAttendance(children[index], value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attendance marked successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to mark attendance')),
                      );
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}