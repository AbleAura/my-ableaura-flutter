import 'package:flutter/material.dart';
import 'attendance_view_screen.dart';
import '../../services/student_service.dart';
import '../../models/child.dart';
import 'children_list_screen.dart';

class AttendanceMenuScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AttendanceMenuScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<AttendanceMenuScreen> createState() => _AttendanceMenuScreenState();
}

class _AttendanceMenuScreenState extends State<AttendanceMenuScreen> {
  bool _isLoading = true;
  String? _error;
  late ChildResponse _childResponse;
  String? _qrCode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await StudentService.getChildrenList();
      if (!mounted) return;

      setState(() {
        _childResponse = response;
      });

      if (response.data.childCount == 1) {
        final child = response.data.childDetails.first;
        final qrCode = await StudentService.getStudentQRCode(child.childId);
        if (!mounted) return;
        setState(() {
          _qrCode = qrCode;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQRCode(int childId, String childName) async {
    try {
      final qrCode = await StudentService.getStudentQRCode(childId);
      if (!mounted) return;
      
      if (qrCode != null) {
        final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
        
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 12),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 60 : 40,
              vertical: isTablet ? 80 : 24,
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    childName,
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Image.network(
                    qrCode,
                    width: isTablet ? 300 : 200,
                    height: isTablet ? 300 : 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: isTablet ? 32 : 16),
                  SizedBox(
                    height: isTablet ? 60 : 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF303030),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 40 : 24,
                          vertical: isTablet ? 12 : 8,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading QR code: $e')),
      );
    }
  }

  Future<void> _handleViewAttendance(int childId, String childName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceViewScreen(
          studentId: childId,
          studentName: childName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: isTablet ? 70 : 56,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 40 : 20,
                        ),
                        child: Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 24 : 16),
                      SizedBox(
                        height: isTablet ? 56 : 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303030),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 24,
                              vertical: isTablet ? 12 : 8,
                            ),
                          ),
                          onPressed: _loadData,
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
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 700 : screenWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_childResponse.data.childCount > 1)
                            _buildMenuOption(
                              context: context,
                              title: 'Show QR Code',
                              subtitle: 'Display QR code for attendance',
                              icon: Icons.qr_code,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildrenListScreen(
                                      navigatorKey: widget.navigatorKey,
                                      onChildSelected: _handleQRCode,
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (_childResponse.data.childCount > 1)
                            SizedBox(height: isTablet ? 24 : 16),
                          _buildMenuOption(
                            context: context,
                            title: 'View Attendance',
                            subtitle: 'Check attendance history',
                            icon: Icons.calendar_month,
                            color: Colors.green,
                            onTap: () {
                              if (_childResponse.data.childCount == 1) {
                                final child = _childResponse.data.childDetails.first;
                                _handleViewAttendance(child.childId, child.name);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChildrenListScreen(
                                      navigatorKey: widget.navigatorKey,
                                      onChildSelected: _handleViewAttendance,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          if (_childResponse.data.childCount == 1 && _qrCode != null) ...[
                            SizedBox(height: isTablet ? 32 : 24),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isTablet ? 20 : 12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      _childResponse.data.childDetails.first.name,
                                      style: TextStyle(
                                        fontSize: isTablet ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 24 : 16),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: isTablet ? 350 : 280,
                                        maxHeight: isTablet ? 350 : 280,
                                      ),
                                      child: Image.network(
                                        _qrCode!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: isTablet ? 16 : 8),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: color, 
                  size: isTablet ? 40 : 32
                ),
              ),
              SizedBox(width: isTablet ? 24 : 16),
              Expanded(
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
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios, 
                size: isTablet ? 20 : 16, 
                color: Colors.grey
              ),
            ],
          ),
        ),
      ),
    );
  }
}