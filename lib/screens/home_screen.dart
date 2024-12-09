// home_screen.dart
import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '/widgets/full_screen_menu.dart';
import 'attendance_menu_screen.dart';
import 'children_list_screen.dart';
import 'connect_with_us_screen.dart';
import 'feedback/feedback_menu_screen.dart';
import 'gallery_screen.dart';
import 'payments/payments_menu_screen.dart';
import 'referral_screen.dart';
import 'whatsapp_channels_screen.dart';
import 'notifications_screen.dart';
import 'progress/progress_view.dart'; // Add this import

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle; // Optional subtitle

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });
}

class HomeScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const HomeScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  List<MenuItem> _getMenuItems(BuildContext context) {
    return [
      // Update the Attendance MenuItem in _getMenuItems method
MenuItem(
  title: 'Attendance',
  icon: Icons.calendar_today_outlined,
  color: Colors.blue,
  subtitle: 'Mark daily attendance',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceMenuScreen(
          navigatorKey: navigatorKey,
        ),
      ),
    );
  },
),
      // Update the Payments MenuItem in _getMenuItems method
MenuItem(
  title: 'My Payments',
  icon: Icons.payment_outlined,
  color: Colors.purple,
  subtitle: 'View and pay fees',
  onTap: () async {
    try {
      final response = await StudentService.getChildrenList();
      if (!context.mounted) return;

      if (response.data.childCount == 1) {
        // Direct navigation to PaymentsMenuScreen for single child
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
        // Show child selection screen for multiple children
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
 // Update the Progress Panel MenuItem in _getMenuItems method
MenuItem(
  title: 'Progress Panel',
  icon: Icons.trending_up,
  color: Colors.red,
  subtitle: 'Track skill development',
  onTap: () async {
    try {
      final response = await StudentService.getChildrenList();
      if (!context.mounted) return;

      if (response.data.childCount == 1) {
        // Direct navigation to ProgressView for single child
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
        // Show child selection screen for multiple children
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
MenuItem(
  title: 'My Child\'s Gallery',
  icon: Icons.photo_library_outlined,
  color: Colors.teal,
  subtitle: 'View photos and videos',
  onTap: () async {
    try {
      final response = await StudentService.getChildrenList();
      if (!context.mounted) return;

      if (response.data.childCount == 1) {
        // Direct navigation for single child
        final child = response.data.childDetails.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GalleryScreen(
              studentId: child.childId,
              studentName: child.name,
            ),
          ),
        );
      } else {
        // Show child selection for multiple children
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildrenListScreen(
              navigatorKey: navigatorKey,
              onChildSelected: (childId, childName) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GalleryScreen(
                      studentId: childId,
                      studentName: childName,
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
       MenuItem(
        title: 'My Referrals',
        icon: Icons.people_outline,
        color: Colors.orange,
        subtitle: 'Refer friends and earn',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReferralScreen(navigatorKey: navigatorKey),
            ),
          );
        },
      ),
     
     
   
     
      MenuItem(
  title: 'Feedback',
  icon: Icons.feedback_outlined,
  color: Colors.purple,
  subtitle: 'Share your thoughts with us',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackMenuScreen(
          navigatorKey: navigatorKey,
        ),
      ),
    );
  },
),
 MenuItem(
        title: 'Connect to WhatsApp',
        icon: Icons.chat_bubble_outline,
        color: Colors.green,
        subtitle: 'Join our channels',
        onTap: () {
          print('Navigating to WhatsApp Channels');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WhatsAppChannelsScreen(navigatorKey: navigatorKey),
            ),
          );
        },
      ),
MenuItem(
  title: 'Connect with Us',
  icon: Icons.share_outlined,
  color: Colors.indigo,
  subtitle: 'Follow us on social media',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConnectWithUsScreen(
          navigatorKey: navigatorKey,
        ),
      ),
    );
  },
),
    ];
  }

  void _showFullScreenMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => FullScreenMenu(
          navigatorKey: navigatorKey,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          navigatorKey: navigatorKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sports Academy',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => _showFullScreenMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic if needed
          await Future.delayed(Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sports Academy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return _buildMenuCard(
                      title: item.title,
                      icon: item.icon,
                      color: item.color,
                      subtitle: item.subtitle,
                      onTap: item.onTap,
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}