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
  String? _shortUrl; // Add this
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF303030),
          tabs: const [
            Tab(text: 'Share & Earn'),
            Tab(text: 'My Referrals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareTab(),
          _buildMyReferralsTab(),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRewardsCard(),
              const SizedBox(height: 24),
              _buildReferralCodeCard(),
              const SizedBox(height: 24),
              _buildShareButton(),
              if (_stats != null) ...[
                const SizedBox(height: 24),
                _buildStatsGrid(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF303030)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Refer & Get Free Sessions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRewardPoint('Get 1 free session for each referral'),
            _buildRewardPoint('No limit on referrals'),
            _buildRewardPoint(
                'Free session after your referral completes 1 month'),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : (_referralCode ?? 'Error'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.copy, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton.icon(
      onPressed: _shareReferralCode,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF303030),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.share, color: Colors.white), // Added color here
      label: const Text(
        'Share with Friends',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Added this line
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Referrals',
          _stats!['total_referrals'].toString(),
          Icons.people_outline,
          Colors.blue,
        ),
        _buildStatCard(
          'Completed',
          _stats!['completed_referrals'].toString(),
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatCard(
          'Pending',
          _stats!['pending_referrals'].toString(),
          Icons.pending_outlined,
          Colors.orange,
        ),
        _buildStatCard(
          'Sessions Earned',
          _stats!['sessions_earned'].toString(),
          Icons.star_outline,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReferralsTab() {
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
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF303030),
                  ),
                  child: const Text('Retry'),
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
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No referrals yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your referral code to get started',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: referrals.length,
            itemBuilder: (context, index) =>
                _buildReferralCard(referrals[index]),
          ),
        );
      },
    );
  }

  Widget _buildReferralCard(ReferralDetail referral) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          referral.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(referral.phone),
            Text(
              'Referred on: ${DateFormat('MMM d, yyyy').format(referral.createdAt)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (referral.meetingScheduledAt != null) // Added
              Text(
                'Meeting Scheduled: ${DateFormat('MMM d, yyyy').format(referral.meetingScheduledAt!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            if (referral.registrationDate != null)
              Text(
                'Registered: ${DateFormat('MMM d, yyyy').format(referral.registrationDate!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            if (referral.paymentCompletionDate != null)
              Text(
                'Completed: ${DateFormat('MMM d, yyyy').format(referral.paymentCompletionDate!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusChip(referral.displayStatus, referral.statusColor),
            if (referral.rewardStatus == 'credited')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Session Credited',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
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
