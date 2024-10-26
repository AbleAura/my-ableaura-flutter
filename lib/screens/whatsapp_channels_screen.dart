import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppChannel {
  final String name;
  final String url;
  final String description;
  final IconData icon;

  WhatsAppChannel({
    required this.name,
    required this.url,
    required this.description,
    required this.icon,
  });
}

class WhatsAppChannelsScreen extends StatelessWidget {
   final GlobalKey<NavigatorState> navigatorKey;

  // Remove const from constructor
   WhatsAppChannelsScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  final List<WhatsAppChannel> channels = [
    WhatsAppChannel(
      name: 'Sports Academy Channel',
      url: 'https://whatsapp.com/channel/0029VarM9HF8vd1MydRFkU3U',
      description: 'Join our Sports Academy channel for latest updates and announcements',
      icon: Icons.sports,
    ),
    WhatsAppChannel(
      name: 'Ableaura Channel',
      url: 'https://whatsapp.com/channel/0029Vankb2gLo4hYlhzUNQ38',
      description: 'Stay connected with Ableaura community',
      icon: Icons.people,
    ),
    WhatsAppChannel(
      name: 'Cosmic Homes',
      url: 'https://whatsapp.com/channel/0029VannQd5LSmbiGuEV423y',
      description: 'Join Cosmic Homes channel for updates',
      icon: Icons.home,
    ),
  ];

  Future<void> _openWhatsAppChannel(BuildContext context, String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please make sure WhatsApp is installed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Channels'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Our Channels',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay updated with latest news and announcements',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ...channels.map((channel) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => _openWhatsAppChannel(context, channel.url),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              channel.icon,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  channel.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  channel.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )).toList(),
              // WhatsApp info card
              Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure you have WhatsApp installed to join these channels',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}