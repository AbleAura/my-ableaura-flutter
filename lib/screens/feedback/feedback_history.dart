// lib/screens/feedback_history_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/feedback.dart';
import '../../services/feedback_service.dart';
import '../../widgets/feedback_detail_dialog.dart';
import '../../widgets/attachments_bottom_sheet.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const FeedbackHistoryScreen({
    Key? key,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _FeedbackHistoryScreenState createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  bool _isLoading = true;
  List<FeedbackModel> _feedbackHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbackHistory();
  }

  Future<void> _loadFeedbackHistory() async {
    try {
      final history = await FeedbackService.getFeedbacks();
      if (mounted) {
        setState(() {
          _feedbackHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'complaint':
        return Colors.red;
      case 'suggestion':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFeedbackDetail(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailDialog(feedback: feedback),
    );
  }

  void _showAttachments(BuildContext context, FeedbackModel feedback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentsBottomSheet(
        attachments: feedback.attachments,
        title: feedback.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeedbackHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _feedbackHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback history found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _feedbackHistory.length,
                    itemBuilder: (context, index) {
                      final feedback = _feedbackHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showFeedbackDetail(feedback),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        feedback.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      feedback.feedbackType?.name.toLowerCase() == 'complaint'
                                          ? Icons.warning_amber_rounded
                                          : Icons.lightbulb_outline,
                                      color: _getTypeColor(feedback.feedbackType?.name ?? 'unknown'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildChip(
                                      feedback.feedbackType?.name ?? 'Unknown Type',
                                      _getTypeColor(feedback.feedbackType?.name ?? 'unknown'),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildChip(
                                      feedback.status,
                                      _getStatusColor(feedback.status),
                                    ),
                                  ],
                                ),
                                if (feedback.description != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    feedback.description!,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (feedback.voiceNotePath != null)
                                          GestureDetector(
                                            onTap: () => _showFeedbackDetail(feedback),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.mic, size: 16, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Play Voice Note',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (feedback.voiceNotePath != null && feedback.attachments.isNotEmpty)
                                          const SizedBox(width: 16),
                                        if (feedback.attachments.isNotEmpty)
                                          GestureDetector(
                                            onTap: () => _showAttachments(context, feedback),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${feedback.attachments.length} Attachment${feedback.attachments.length > 1 ? 's' : ''}',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      DateFormat('MMM d, y').format(feedback.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}