// otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '/services/auth_service.dart';
import 'home_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final GlobalKey<NavigatorState> navigatorKey;

  const OtpVerificationScreen({
    Key? key,
    required this.phone,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _resendTimer = 30;
  late Timer _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    // Add focus node listeners
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          // Clear any previous input when focusing on an empty field
          for (int j = i + 1; j < _controllers.length; j++) {
            _controllers[j].clear();
          }
        }
      });
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_resendTimer == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  Future<void> _resendOTP() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.sendOTP(widget.phone);
      setState(() {
        _resendTimer = 30;
      });
      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.verifyOTP(widget.phone, otp);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeScreen(navigatorKey: widget.navigatorKey)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get device size and check if it's a tablet
    final Size deviceSize = MediaQuery.of(context).size;
    final bool isTablet = deviceSize.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back, 
            color: Colors.black,
            size: isTablet ? 28 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32 : 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VERIFY DETAILS',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 8),
                Text(
                  'OTP sent to +91-${widget.phone}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
                SizedBox(height: isTablet ? 60 : 40),
                Text(
                  'ENTER OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: isTablet ? 100 : 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: isTablet ? 36 : 24, 
                          fontWeight: FontWeight.bold
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: isTablet ? 2 : 1,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF303030), 
                              width: isTablet ? 3 : 2
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 8
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(1),
                        ],
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          }
                          if (value.length == 1 && index == 3) {
                            _focusNodes[index].unfocus();
                            _verifyOTP(); // Auto verify when all digits are entered
                          }
                          if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 36 : 24),
                
                // Resend OTP Button
                Center(
                  child: GestureDetector(
                    onTap: _resendTimer == 0 ? _resendOTP : null,
                    child: Text(
                      _resendTimer > 0
                          ? "Didn't receive the OTP? Retry in 00:${_resendTimer.toString().padLeft(2, '0')}"
                          : "Didn't receive the OTP? Tap to resend",
                      style: TextStyle(
                        color: _resendTimer > 0 ? Colors.grey : const Color(0xFF303030),
                        fontSize: isTablet ? 16 : 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 36 : 24),
                
                // Verify Button
                SizedBox(
                  height: isTablet ? 60 : 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF303030),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: isTablet ? 24 : 20,
                            width: isTablet ? 24 : 20,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'VERIFY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}