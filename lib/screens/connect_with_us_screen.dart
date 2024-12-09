// lib/screens/connect_with_us_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectWithUsScreen extends StatelessWidget {
 final GlobalKey<NavigatorState> navigatorKey;

 const ConnectWithUsScreen({
   Key? key,
   required this.navigatorKey,
 }) : super(key: key);

@override
Widget build(BuildContext context) {
 return Scaffold(
   appBar: AppBar(
     title: const Text('Connect with Us'),
     backgroundColor: Colors.white,
     foregroundColor: Colors.black,
     elevation: 0,
   ),
   body: SingleChildScrollView(
     padding: const EdgeInsets.all(16.0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'Follow us on social media',
           style: const TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
           ),
         ),
         const SizedBox(height: 24),
         _buildSocialButton(
           context,
           'Follow us on YouTube',
           'assets/icons/youtube.png',
           'https://www.youtube.com/@ableaura4943',
           Colors.red,
         ),
         _buildSocialButton(
           context,
           'Follow us on Facebook', 
           'assets/icons/facebook.png',
           'https://www.facebook.com/able_aura',
           Colors.blue,
         ),
         _buildSocialButton(
           context,
           'Follow us on Instagram',
           'assets/icons/instagram.png', 
           'https://www.instagram.com/able_aura',
           Colors.purple,
         ),
         _buildSocialButton(
           context,
           'Follow us on WhatsApp',
           'assets/icons/whatsapp.png',
           'https://api.whatsapp.com/send/?phone=917868880000&text=Hello%2C+I+have+a+question+about+Ableaura+Sports+Academy',
           Colors.green,
         ),
         _buildSocialButton(
           context,
           'Rate us on Google',
           'assets/icons/google.png',
           'https://g.page/r/CZj24Yh2DAFwEBM/review',
           Colors.blue,
         ),
       ].map((widget) => Padding(
         padding: EdgeInsets.symmetric(vertical: 8),
         child: widget,
       )).toList(),
     ),
   ),
 );
}

Widget _buildSocialButton(
 BuildContext context,
 String text,
 String iconPath,
 String url,
 Color color,
) {
 return Container(
   decoration: BoxDecoration(
     color: Colors.grey[50],
     borderRadius: BorderRadius.circular(12),
   ),
   child: ListTile(
     leading: Image.asset(iconPath, width: 24, height: 24),
     title: Text(text),
     trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
     onTap: () => _launchUrl(url),
   ),
 );
}

 Future<void> _launchUrl(String url) async {
   if (!await launchUrl(Uri.parse(url))) {
     throw Exception('Could not launch $url');
   }
 }
}