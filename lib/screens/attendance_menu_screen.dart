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
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    childName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Image.network(qrCode),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF303030),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF303030),
                        ),
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  _childResponse.data.childDetails.first.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Image.network(_qrCode!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}