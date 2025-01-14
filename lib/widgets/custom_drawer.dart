import 'package:flutter/material.dart';
import '../screens/profile/profile_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
               // Add Profile menu item here
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Your Profile',
              subtitle: 'View Profile Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'Attendances',
              subtitle: 'Manage Daily Attendances',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.payment,
              title: 'Payments',
              subtitle: 'Payments & History',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.trending_up,
              title: 'Progress panel',
              subtitle: 'View my child\'s progress',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.chat,
              title: 'WhatsApp Channels',
              subtitle: 'View Ableaura\'s Channels',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Referrals',
              subtitle: 'Refer Friends',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.feedback,
              title: 'Feedback',
              subtitle: 'Share your thoughts with us',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.share,
              title: 'Connect with Us',
              subtitle: 'Follow us on social media',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red[400]),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.red[400]),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
    );
  }
}