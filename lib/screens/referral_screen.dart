import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../services/referral_service.dart';
import '../models/referral_detail.dart';
import 'dart:io';

class ReferralScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ReferralScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _referralCode;
  String? _shortUrl;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ReferralService.generateCode();
      final statsResponse = await ReferralService.getReferralStats();

      if (mounted) {
        setState(() {
          _referralCode = response['referral_code'];
          _shortUrl = response['short_url'];
          _stats = statsResponse['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _shareReferralCode() async {
    if (_referralCode == null || _shortUrl == null) return;

    try {
      final String shareText = '''
Join Ableaura Sports Academy!

Transform your child's sporting journey with Ableaura's expert coaching and personalized programs.

🏆 Expert Coach Training
🎯 Professional Sports Programs
🛡️ Safe Learning Environment
⭐ Personalized Development
📱 Real-time Progress Tracking

Schedule your FREE consultation call now!
👉 $_shortUrl

Join the Ableaura family today and give your child the advantage they deserve!
''';

      // Get the image from assets and save to temporary file
      final bytes = await rootBundle.load('assets/whatsapp-share-img.jpg');
      final tempDir = await getTemporaryDirectory();
      final tempImageFile = File('${tempDir.path}/referral_image.jpg');
      await tempImageFile.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
      XFile xfile = XFile(tempImageFile.path);
      // Share both image and text
      await Share.shareXFiles(
        [xfile],
        text: shareText,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Refer & Earn',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF303030),
          indicatorWeight: isTablet ? 3 : 2,
          labelStyle: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              text: 'Share & Earn',
              height: isTablet ? 56 : 46,
            ),
            Tab(
              text: 'My Referrals',
              height: isTablet ? 56 : 46,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareTab(isTablet),
          _buildMyReferralsTab(isTablet),
        ],
      ),
    );
  }

  Widget _buildShareTab(bool isTablet) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 700 : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRewardsCard(isTablet),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildReferralCodeCard(isTablet),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildShareButton(isTablet),
                  if (_stats != null) ...[
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildStatsGrid(isTablet),
                  ],
                  // Add extra space at bottom to prevent overflow
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsCard(bool isTablet) {
    return Card(
      elevation: isTablet ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF303030)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Text(
                  'Refer & Get Free Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 24 : 16),
            _buildRewardPoint('Get 1 free session for each referral', isTablet),
            _buildRewardPoint('No limit on referrals', isTablet),
            _buildRewardPoint(
                'Free session after your referral completes 1 month', isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardPoint(String text, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.white70,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard(bool isTablet) {
    return Card(
      elevation: isTablet ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            InkWell(
              onTap: () {
                if (_referralCode != null) {
                  Clipboard.setData(ClipboardData(text: _referralCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied!')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : (_referralCode ?? 'Error'),
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.copy, 
                      color: Colors.grey[600],
                      size: isTablet ? 28 : 24,
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

  Widget _buildShareButton(bool isTablet) {
    return SizedBox(
      height: isTablet ? 60 : 48,
      child: ElevatedButton.icon(
        onPressed: _shareReferralCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF303030),
          padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
        ),
        icon: Icon(
          Icons.share, 
          color: Colors.white,
          size: isTablet ? 24 : 20,
        ),
        label: Text(
          'Share with Friends',
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isTablet) {
    // For tablets in landscape, keep 4 columns, otherwise use 2 columns
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final crossAxisCount = isTablet && isLandscape ? 4 : 2;
    
    // Adjust aspect ratio based on device and orientation - increase height for phone
    final childAspectRatio = isTablet 
        ? (isLandscape ? 2.0 : 1.8)  // Higher aspect ratio for tablets
        : 1.4;                       // Better aspect ratio for phones - lower than before
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: isTablet ? 20 : 16,
      crossAxisSpacing: isTablet ? 20 : 16,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          'Total Referrals',
          _stats!['total_referrals'].toString(),
          Icons.people_outline,
          Colors.blue,
          isTablet,
        ),
        _buildStatCard(
          'Completed',
          _stats!['completed_referrals'].toString(),
          Icons.check_circle_outline,
          Colors.green,
          isTablet,
        ),
        _buildStatCard(
          'Pending',
          _stats!['pending_referrals'].toString(),
          Icons.pending_outlined,
          Colors.orange,
          isTablet,
        ),
        _buildStatCard(
          'Sessions Earned',
          _stats!['sessions_earned'].toString(),
          Icons.star_outline,
          Colors.purple,
          isTablet,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isTablet) {
    return Card(
      elevation: isTablet ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            Icon(
              icon, 
              color: color, 
              size: isTablet ? 28 : 24,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            // Wrap value in FittedBox to prevent overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: isTablet ? 4 : 2),
            // Wrap title in FittedBox to prevent overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 14 : 11, // Smaller font on phones
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReferralsTab(bool isTablet) {
    return FutureBuilder<List<ReferralDetail>>(
      future: ReferralService.getReferrals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48 : 24),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isTablet ? 18 : 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                SizedBox(
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF303030),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 32 : 24,
                        vertical: isTablet ? 12 : 8,
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

        final referrals = snapshot.data ?? [];

        if (referrals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: isTablet ? 80 : 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: isTablet ? 24 : 16),
                Text(
                  'No referrals yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 20 : 16,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Share your referral code to get started',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 800 : double.infinity,
              ),
              child: ListView.builder(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                itemCount: referrals.length,
                itemBuilder: (context, index) =>
                    _buildReferralCard(referrals[index], isTablet),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferralCard(ReferralDetail referral, bool isTablet) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      elevation: isTablet ? 2 : 1,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        referral.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        referral.phone,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        'Referred on: ${DateFormat('MMM d, yyyy').format(referral.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600], 
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                      if (referral.meetingScheduledAt != null)
                        Padding(
                          padding: EdgeInsets.only(top: isTablet ? 4 : 2),
                          child: Text(
                            'Meeting Scheduled: ${DateFormat('MMM d, yyyy').format(referral.meetingScheduledAt!)}',
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      if (referral.registrationDate != null)
                        Padding(
                          padding: EdgeInsets.only(top: isTablet ? 4 : 2),
                          child: Text(
                            'Registered: ${DateFormat('MMM d, yyyy').format(referral.registrationDate!)}',
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                      if (referral.paymentCompletionDate != null)
                        Padding(
                          padding: EdgeInsets.only(top: isTablet ? 4 : 2),
                          child: Text(
                            'Completed: ${DateFormat('MMM d, yyyy').format(referral.paymentCompletionDate!)}',
                            style: TextStyle(
                              color: Colors.grey[600], 
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusChip(referral.displayStatus, referral.statusColor, isTablet),
                    if (referral.rewardStatus == 'credited')
                      Container(
                        margin: EdgeInsets.only(top: isTablet ? 6 : 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        ),
                        child: Text(
                          'Session Credited',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12, 
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}