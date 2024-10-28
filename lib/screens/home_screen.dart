// home_screen.dart
import 'package:flutter/material.dart';
import '/widgets/full_screen_menu.dart';
import 'children_list_screen.dart';
import 'whatsapp_channels_screen.dart';
import 'payment_selection_screen.dart';
import 'notifications_screen.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class HomeScreen extends StatelessWidget {
 final GlobalKey<NavigatorState> navigatorKey;

  // Remove const from constructor since navigatorKey can't be const
  const HomeScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

// In your HomeScreen class, update the _getMenuItems method:

List<MenuItem> _getMenuItems(BuildContext context) {
  return [
    MenuItem(
      title: 'Attendance',
      icon: Icons.calendar_today_outlined,
      color: Colors.blue,
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
      onTap: () {
        print('Navigating to Referrals');
        // Add navigation when screen is ready
      },
    ),
    MenuItem(
      title: 'My Payments',
      icon: Icons.payment_outlined,
      color: Colors.purple,
      onTap: () {
        print('Navigating to Payments Selection');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSelectionScreen(navigatorKey: navigatorKey),
          ),
        );
      },
    ),
    MenuItem(
      title: 'Progress Panel',
      icon: Icons.trending_up,
      color: Colors.red,
      onTap: () {
        print('Navigating to Progress Panel');
        // Add navigation when screen is ready
      },
    ),
    MenuItem(
      title: 'My Child\'s Gallery',
      icon: Icons.photo_library_outlined,
      color: Colors.teal,
      onTap: () {
        print('Navigating to Gallery');
        // Add navigation when screen is ready
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
      body: SingleChildScrollView(
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
                    onTap: item.onTap,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
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
            ],
          ),
        ),
      ),
    );
  }
}