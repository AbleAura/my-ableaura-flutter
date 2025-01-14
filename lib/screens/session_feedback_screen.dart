import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SessionFeedbackScreen extends StatefulWidget {
  final int sessionId;
  final String coachName;

  const SessionFeedbackScreen({
    Key? key,
    required this.sessionId,
    required this.coachName,
  }) : super(key: key);

  @override
  State<SessionFeedbackScreen> createState() => _SessionFeedbackScreenState();
}

class _SessionFeedbackScreenState extends State<SessionFeedbackScreen> {
  int _rating = 0;
  final List<String> _selectedAspects = [];
  final TextEditingController _feedbackController = TextEditingController();
  File? _attachment;
  bool _isSubmitting = false;

  final List<String> _lowRatingIssues = [
    'Coach Punctuality',
    'Coach Training',
    'Coach Handling',
    'Training Method',
    'Training Quality',
    'Safety Issues',
  ];

  final List<String> _highRatingAspects = [
    'Coach Punctuality',
    'Coach Training',
    'Coach Handling',
    'Training Method',
    'Training Quality',
    'Safety',
  ];

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        allowCompression: true,
        withData: true,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        
        // Check if file size is less than 30MB
        if (fileSize > 30 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File size should be less than 30MB')),
          );
          return;
        }

        setState(() => _attachment = file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate your session with ${widget.coachName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                      _selectedAspects.clear(); // Clear selections when rating changes
                    });
                  },
                );
              }),
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 24),
              Text(
                _rating == 5 
                    ? 'What do you think went well with the session?'
                    : 'What did you not like about the session?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                _rating == 5 ? _highRatingAspects.length : _lowRatingIssues.length,
                (index) {
                  final aspect = _rating == 5 
                      ? _highRatingAspects[index]
                      : _lowRatingIssues[index];
                  return CheckboxListTile(
                    title: Text(aspect),
                    value: _selectedAspects.contains(aspect),
                    activeColor: _rating == 5 ? Colors.green : Colors.red,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedAspects.add(aspect);
                        } else {
                          _selectedAspects.remove(aspect);
                        }
                      });
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Additional Comments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feedbackController,
              maxLength: 500,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about the session...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_attachment != null 
                ? 'File Selected: ${_attachment!.path.split('/').last}'
                : 'Attach File (max 30MB)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF303030),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting || _rating == 0 
                  ? null 
                  : _submitFeedback,
                child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);
    try {
      // TODO: Implement API call
      await Future.delayed(const Duration(seconds: 2)); // Simulated API call
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}