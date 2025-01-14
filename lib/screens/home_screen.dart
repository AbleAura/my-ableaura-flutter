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
import 'progress/progress_view.dart';
import 'home_sessions_screen.dart';
import '../screens/profile/profile_screen.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

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

  // Your existing _getMenuItems method stays exactly the same
List<MenuItem> _getMenuItems(BuildContext context) {
    return [
      MenuItem(
        title: 'Your Profile',
        icon: Icons.person_outline,
        color: Colors.blue,
        subtitle: 'View Profile Details',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
      ),
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
        title: 'At Home Sessions',
        icon: Icons.home_outlined,
        color: Colors.teal,
        subtitle: 'View your scheduled home training sessions',
        onTap: () async {
          try {
            final response = await StudentService.getChildrenList();
            if (!context.mounted) return;

            if (response.data.childCount == 1) {
              final child = response.data.childDetails.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeSessionsScreen(
                    studentId: child.childId,
                    studentName: child.name,
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
                          builder: (context) => HomeSessionsScreen(
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

  double _calculateAspectRatio(double screenWidth) {
    if (screenWidth > 600) {
      return 1.4; // For tablets
    } else if (screenWidth > 400) {
      return 1.1; // For larger phones
    } else {
      return 0.9; // For smaller phones
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => _showFullScreenMenu(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    const SizedBox(height: 4),
                    const Text(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 600 ? 3 : 2,
                        childAspectRatio: _calculateAspectRatio(screenWidth),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 180;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: isSmallScreen ? 24 : 28,
                      color: color,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: isSmallScreen ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}