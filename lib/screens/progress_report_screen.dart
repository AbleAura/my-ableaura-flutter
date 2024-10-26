import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/user_provider.dart';
import '/services/api_service.dart';
import '/widgets/uber_style_box.dart';

class ProgressReportScreen extends StatelessWidget {
   final GlobalKey<NavigatorState> navigatorKey;

  // Remove const from constructor
  const ProgressReportScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final children = userProvider.children;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Report'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: ApiService.getProgressReport(children[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Text('No data available');
              }

              final report = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: UberStyleBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(children[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('Overall Progress: ${report['overallProgress']}%'),
                        const SizedBox(height: 5),
                        Text('Attendance: ${report['attendance']}%'),
                        const SizedBox(height: 5),
                        Text('Performance: ${report['performance']}'),
                        const SizedBox(height: 5),
                        Text('Comments: ${report['comments']}'),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}