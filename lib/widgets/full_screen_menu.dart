// full_screen_menu.dart
import 'package:flutter/material.dart';
import '../screens/children_list_screen.dart';
import '../screens/connect_with_us_screen.dart';
import '../screens/feedback/feedback_menu_screen.dart';
import '../screens/payments/payments_menu_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/progress/progress_view.dart';
import '../services/student_service.dart';

class FullScreenMenu extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const FullScreenMenu({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    final bool shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldLogout && context.mounted) {
      await StudentService.logout(context, navigatorKey);
    }
  }

  void _handleMenuItemTap(BuildContext context, String route) {
    Navigator.pop(context); // Close menu
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            const Text(
              'Menu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
              _buildMenuItem(
              context: context,
              icon: Icons.account_circle_outlined,
              title: 'Your Profile',
              subtitle: 'View and edit your profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.calendar_today,
              title: 'Attendances',
              subtitle: 'Manage Daily Attendances',
              onTap: () => _handleMenuItemTap(context, '/attendance'),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.payment,
              title: 'Payments',
              subtitle: 'Payments & History',
              onTap: () async {
                try {
                  final response = await StudentService.getChildrenList();
                  if (!context.mounted) return;
                  
                  Navigator.pop(context); // Close menu

                  if (response.data.childCount == 1) {
                    final child = response.data.childDetails.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentsMenuScreen(
                          studentId: child.childId,
                          studentName: child.name,
                          navigatorKey: navigatorKey,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildrenListScreen(
                          navigatorKey: navigatorKey,
                          onChildSelected: (childId, childName) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentsMenuScreen(
                                  studentId: childId,
                                  studentName: childName,
                                  navigatorKey: navigatorKey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading children: $e')),
                  );
                }
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.trending_up,
              title: 'Progress panel',
              subtitle: 'View my child\'s progress',
              onTap: () async {
                try {
                  final response = await StudentService.getChildrenList();
                  if (!context.mounted) return;
                  
                  Navigator.pop(context); // Close menu

                  if (response.data.childCount == 1) {
                    final child = response.data.childDetails.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgressView(
                          childId: child.childId,
                          childName: child.name,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildrenListScreen(
                          navigatorKey: navigatorKey,
                          onChildSelected: (childId, childName) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressView(
                                  childId: childId,
                                  childName: childName,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading children: $e')),
                  );
                }
              },
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.chat,
              title: 'WhatsApp Channels',
              subtitle: 'View Ableaura\'s Channels',
              onTap: () => _handleMenuItemTap(context, '/channels'),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.people,
              title: 'Referrals',
              subtitle: 'Refer Friends',
              onTap: () => _handleMenuItemTap(context, '/referral'),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.feedback_outlined,
              title: 'Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeedbackMenuScreen(
                    navigatorKey: navigatorKey,
                  ),
                ),
              ),
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.share_outlined,
              title: 'Connect with Us',
              subtitle: 'Follow us on social media',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConnectWithUsScreen(
                    navigatorKey: navigatorKey,
                  ),
                ),
              ),
            ),
          
            const Divider(height: 40, thickness: 1),
            InkWell(
              onTap: () => _handleLogout(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 16),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF303030)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}