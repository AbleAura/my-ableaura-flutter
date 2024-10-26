import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
   final GlobalKey<NavigatorState> navigatorKey;

  const ReferralScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _ReferralScreenState createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
        });
      }
    } catch (e) {
      print('Error loading contacts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _contacts);
    } else {
      setState(() {
        _filteredContacts = _contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E0052),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Reward Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refer friends & Earn ₹2500!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRewardPoint(
                  'You get ₹150 cashback when a friend places their first order using referral coupon.',
                ),
                _buildRewardPoint(
                  'Friend gets flat ₹90 off + free delivery on their first order',
                ),
                _buildRewardPoint(
                  'You get ₹2500 cashback for the first fifty successful referrals',
                ),
              ],
            ),
          ),

          // Main Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Share section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Get rewards by inviting your\nfriends to join Sports Academy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share),
                          label: const Text('Share link in a group'),
                          onPressed: _shareReferralLink,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Find your friends',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      onChanged: _filterContacts,
                    ),
                  ),

                  // Contacts List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredContacts.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _filteredContacts.length) {
                                return _buildFAQSection();
                              }

                              final contact = _filteredContacts[index];
                              final phone = contact.phones.isNotEmpty 
                                  ? contact.phones.first.number 
                                  : '';

                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      contact.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(phone),
                                    trailing: TextButton(
                                      child: const Text(
                                        'Invite',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () => _inviteContact(phone),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'FAQ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildFAQItem(
          'How can I refer a friend?',
          'Share your referral link with friends and family.',
        ),
        _buildFAQItem(
          'What is a successful referral?',
          'A referral would be considered successful only after your friend joins Sports Academy using the referral code.',
        ),
        _buildFAQItem(
          'How much cashback can I earn?',
          'You can earn up to ₹2500 cashback by successfully referring friends. You get ₹150 for each successful referral.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }

  Future<void> _shareReferralLink() async {
    const String referralCode = "YOUR_REFERRAL_CODE"; // Get from your backend
    const String message = '''
Join Sports Academy with my referral code!

Use code: $referralCode to get ₹90 off + free delivery on your first order.

Download now: [App Link]
    ''';

    try {
      await Share.share(message);
    } catch (e) {
      print('Error sharing referral link: $e');
    }
  }

  Future<void> _inviteContact(String phone) async {
    const String referralCode = "YOUR_REFERRAL_CODE"; // Get from your backend
    const String message = '''
Join Sports Academy with my referral code!

Use code: $referralCode to get ₹90 off + free delivery on your first order.

Download now: [App Link]
    ''';

    try {
      await Share.share(message);
    } catch (e) {
      print('Error inviting contact: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}