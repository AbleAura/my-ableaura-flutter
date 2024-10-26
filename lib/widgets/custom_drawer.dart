import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF303030),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            title: 'Attendances',
            subtitle: 'Manage Daily Attendances',
            onTap: () {
              // Navigate to Attendances screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.chat,
            title: 'WhatsApp Channels',
            subtitle: 'View Ableaura\'s Channels',
            onTap: () {
              // Navigate to WhatsApp Channels screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'Referrals',
            subtitle: 'Refer Friends',
            onTap: () {
              // Navigate to Referrals screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.payment,
            title: 'Payments',
            subtitle: 'Payments & History',
            onTap: () {
              // Navigate to Payments screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.location_on,
            title: 'Addresses',
            subtitle: 'Add & Edit Address',
            onTap: () {
              // Navigate to Addresses screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.trending_up,
            title: 'Progress panel',
            subtitle: 'View my child\'s progress',
            onTap: () {
              // Navigate to Progress panel screen
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // Implement logout functionality
              Navigator.pop(context);
              // You might want to navigate to the login screen here
              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
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
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}