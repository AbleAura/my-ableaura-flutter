// lib/screens/feedback/feedback_menu_screen.dart
import 'package:flutter/material.dart';
import 'feedback_form_screen.dart';

class FeedbackMenuScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const FeedbackMenuScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Your Feedback',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a category to proceed',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildFeedbackOption(
              context,
              title: 'Complaints',
              subtitle: 'Report an issue or complaint',
              icon: Icons.warning_amber_rounded,
              color: Colors.red,
              onTap: () => _navigateToForm(context, 'complaint'),
            ),
            const SizedBox(height: 16),
            _buildFeedbackOption(
              context,
              title: 'Suggestions',
              subtitle: 'Share your ideas and suggestions',
              icon: Icons.lightbulb_outline,
              color: Colors.green,
              onTap: () => _navigateToForm(context, 'suggestion'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackFormScreen(
          feedbackType: type,
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }

  Widget _buildFeedbackOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}