// home_screen.dart
import 'package:flutter/material.dart';
import '/widgets/full_screen_menu.dart';
import 'children_list_screen.dart';
import 'feedback/feedback_menu_screen.dart';
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
      MenuItem(
        title: 'Attendance',
        icon: Icons.calendar_today_outlined,
        color: Colors.blue,
        subtitle: 'Mark daily attendance',
        onTap: () {
          print('Navigating to Attendance');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildrenListScreen(navigatorKey: navigatorKey),
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
  title: 'My Payments',
  icon: Icons.payment_outlined,
  color: Colors.purple,
  subtitle: 'View and pay fees',
  onTap: () {
    print('Navigating to Payments Selection');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildrenListScreen(
          navigatorKey: navigatorKey,
          onChildSelected: (childId, childName) {
            // After child is selected, navigate to PaymentsMenuScreen
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
  },
),
      MenuItem(
        title: 'Progress Panel',
        icon: Icons.trending_up,
        color: Colors.red,
        subtitle: 'Track skill development',
        onTap: () {
          print('Navigating to Progress Panel');
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
        },
      ),
      MenuItem(
        title: 'My Child\'s Gallery',
        icon: Icons.photo_library_outlined,
        color: Colors.teal,
        subtitle: 'View photos and videos',
        onTap: () {
          print('Navigating to Gallery');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coming soon!')),
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