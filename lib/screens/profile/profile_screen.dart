import 'package:flutter/material.dart';
import '../../models/profile.dart';
import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
      ),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: isTablet ? 64 : 48,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Text(
                    'Unable to load profile',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    'Please check your connection and try again',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  SizedBox(
                    height: isTablet ? 56 : 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileFuture = ProfileService.getProfile();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303030),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 48 : 32, 
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No profile data available',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            );
          }

          final profile = snapshot.data!;
          final children = profile.childDetails;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: isTablet ? 70 : 50,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person, 
                              size: isTablet ? 70 : 50, 
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          Text(
                            profile.firstName,
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24),

                    // Personal Information Card
                    _buildInfoCard(
                      title: 'Personal Information',
                      children: [
                        _buildInfoRow('Phone', profile.phone, isTablet),
                        _buildInfoRow('Email', profile.email, isTablet),
                      ],
                      isTablet: isTablet,
                    ),
                    SizedBox(height: isTablet ? 24 : 16),

                    // Children Information
                    if (children.isNotEmpty) ...[
                      Text(
                        'Children',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      ...children.map((child) => _buildChildCard(child, isTablet)).toList(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    required bool isTablet,
  }) {
    return Card(
      elevation: isTablet ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 140 : 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child, bool isTablet) {
    return Card(
      elevation: isTablet ? 2 : 1,
      margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              child['name'] ?? 'N/A',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            _buildChildInfoRow('ID', child['unique_id'] ?? 'N/A', isTablet),
            _buildChildInfoRow('Age', _calculateAge(child['dob']), isTablet),
            _buildChildInfoRow('Gender', child['gender'] ?? 'N/A', isTablet),
            _buildChildInfoRow('Blood Group', child['blood_group'] ?? 'N/A', isTablet),
            _buildChildInfoRow('School', child['school_name'] ?? 'N/A', isTablet),
            _buildChildInfoRow('Primary Language', child['primary_language'] ?? 'N/A', isTablet),
            if (child['secondary_language'] != null)
              _buildChildInfoRow('Secondary Language', child['secondary_language'], isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildChildInfoRow(String label, String value, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12.0 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 160 : 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String? dobString) {
    if (dobString == null) return 'N/A';
    
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      
      if (now.month < dob.month || 
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      
      return '$age years';
    } catch (e) {
      return 'N/A';
    }
  }
}