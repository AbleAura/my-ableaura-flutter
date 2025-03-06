import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/auth_service.dart';
import '../services/policy_service.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const LoginScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPolicyDialog(BuildContext context, String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: FutureBuilder<String>(
            future: PolicyService.getPolicyContent(type),
            builder: (context, snapshot) {
              return Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type == 'terms' ? 'Terms & Conditions' : 'Privacy Policy',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (snapshot.hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Error loading content: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showPolicyDialog(context, type);
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Markdown(
                          data: snapshot.data!,
                          selectable: true,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.sendOTP(_phoneController.text);
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phone: _phoneController.text,
            navigatorKey: widget.navigatorKey,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get device size
    final Size deviceSize = MediaQuery.of(context).size;
    final bool isTablet = deviceSize.shortestSide >= 600;
    
    return Scaffold(
      body: Column(
        children: [
          // Header Image that fills the top part of the screen
          Container(
            width: deviceSize.width,
            height: isTablet ? deviceSize.height * 0.4 : 200,
            child: Image.asset(
              'assets/whatsapp-share-img.jpg',
              fit: BoxFit.cover,
              width: deviceSize.width,
            ),
          ),
          
          // Content Area
          Expanded(
            child: SafeArea(
              top: false, // No need for top safe area since image handles that
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 600 : deviceSize.width,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  
                  // Main Content with responsive padding
                  Padding(
                    padding: EdgeInsets.all(isTablet ? 32 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 24, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 8),
                        Text(
                          'Enter your phone number to proceed',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                        SizedBox(height: isTablet ? 60 : 40),
                        
                        // Phone input with responsive sizing
                        Row(
                          children: [
                            // Country code selector
                            Container(
                              height: isTablet ? 64 : 56,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 12
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🇮🇳 +91',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 14,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down, 
                                    color: Colors.grey.shade600,
                                    size: isTablet ? 28 : 24,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 8),
                            
                            // Phone number field
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: 'Mobile number',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey.shade400),
                                  ),
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 16 : 12, 
                                    vertical: isTablet ? 20 : 16
                                  ),
                                  hintStyle: TextStyle(
                                    fontSize: isTablet ? 18 : 14,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                maxLength: 10,
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: isTablet ? 40 : 24),
                        
                        // Continue button with responsive sizing
                        SizedBox(
                          height: isTablet ? 60 : 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF303030),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isTablet ? 8 : 4),
                              ),
                            ),
                            onPressed: _isLoading ? null : _sendOTP,
                            child: _isLoading
                                ? SizedBox(
                                    height: isTablet ? 24 : 20,
                                    width: isTablet ? 24 : 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'CONTINUE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 18 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        
                        SizedBox(height: isTablet ? 24 : 16),
                        
                        // Terms and conditions text
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[600], 
                                fontSize: isTablet ? 14 : 12
                              ),
                              children: [
                                const TextSpan(text: 'By clicking, I accept the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: Color(0xFF303030),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showPolicyDialog(context, 'terms'),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Color(0xFF303030),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showPolicyDialog(context, 'privacy'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}