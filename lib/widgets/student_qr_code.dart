import 'dart:async';

import 'package:flutter/material.dart';
import '../services/student_service.dart';

class StudentQRCode extends StatefulWidget {
  final int studentId;

  const StudentQRCode({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<StudentQRCode> createState() => _StudentQRCodeState();
}

class _StudentQRCodeState extends State<StudentQRCode> {
  late Future<String> _qrCodeFuture;

  @override
  void initState() {
    super.initState();
    _qrCodeFuture = _loadQRCode();
  }

  Future<String> _loadQRCode() async {
    try {
      // This will handle getting or generating the QR code
      return await StudentService.waitForQRCode(widget.studentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _qrCodeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Generating QR Code...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _qrCodeFuture = _loadQRCode();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text('No QR code available'),
          );
        }

        return Image.network(
          snapshot.data!,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load QR code',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}