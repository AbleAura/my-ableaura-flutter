// lib/screens/feedback/feedback_form_screen.dart
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/feedback_type.dart';
import '../../services/feedback_service.dart';
import '../../widgets/recording_indicator.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String feedbackType;
  final GlobalKey<NavigatorState> navigatorKey;

  const FeedbackFormScreen({
    Key? key,
    required this.feedbackType,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  _FeedbackFormScreenState createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final AudioRecorder recorder;
  final _audioPlayer = AudioPlayer();
  late final AudioRecorder _audioRecorder; // Change this line

  File? _voiceNote;
  List<File> _attachments = [];
  List<FeedbackType> _feedbackTypes = [];
  FeedbackType? _selectedType;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
        _audioRecorder = AudioRecorder(); // Initialize here
    _loadFeedbackTypes();
    _checkAndRequestPermissions();  // Add this line
  }
Future<void> _requestPermissions() async {
  try {
    // Check and request recording permissions
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice recording'),
          ),
        );
      }
    }
  } catch (e) {
    print('Error requesting permissions: $e');
  }
}
Future<void> _checkAndRequestPermissions() async {
  final status = await Permission.microphone.status;
  print('Current permission status: $status'); // Debug log
  
  if (status.isDenied || status.isRestricted) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Microphone Permission'),
        content: Text('We need microphone access to record voice notes. Would you like to grant permission?'),
        actions: [
          TextButton(
            child: Text('Not Now'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303030),
            ),
            child: Text('Grant Access'),
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              final newStatus = await Permission.microphone.request();
              print('New permission status: $newStatus'); // Debug log

              if (!mounted) return;

              if (newStatus.isDenied || newStatus.isPermanentlyDenied) {
                _showOpenSettingsDialog();
              } else if (newStatus.isGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Microphone permission granted')),
                );
              }
            },
          ),
        ],
      ),
    );
  } else if (status.isPermanentlyDenied) {
    _showOpenSettingsDialog();
  }
}

void _showOpenSettingsDialog() {
  if (!mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Permission Required'),
      content: Text('Microphone permission is required for voice recording. Please enable it in app settings.'),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF303030),
          ),
          child: Text('Open Settings'),
          onPressed: () async {
            Navigator.pop(context);
            final bool isOpened = await openAppSettings();
            print('Settings opened: $isOpened'); // Debug log
          },
        ),
      ],
    ),
  );
}
// And update the recording method
Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        // Create temp file path for recording
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/recorded_audio.m4a';
        
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() => _isRecording = true);
      } else {
        _checkAndRequestPermissions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

 Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) _voiceNote = File(path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording: $e')),
      );
    }
  }

  Future<void> _loadFeedbackTypes() async {
    try {
      final types = await FeedbackService.getFeedbackTypes();
      setState(() {
        _feedbackTypes = types;
        // Pre-select type based on navigation
        _selectedType = types.firstWhere(
          (type) => type.name.toLowerCase() == widget.feedbackType.toLowerCase(),
          orElse: () => types.first,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  

  Future<void> _playVoiceNote() async {
    if (_voiceNote == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(_voiceNote!.path));
        setState(() => _isPlaying = true);
        
        // Reset playing state when audio finishes
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) setState(() => _isPlaying = false);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to play recording: $e')),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        allowMultiple: true,
      );

      if (result != null) {
        final newFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        if (_attachments.length + newFiles.length > 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 3 files allowed')),
          );
          return;
        }

        // Check file sizes
        for (var file in newFiles) {
          final sizeInMB = file.lengthSync() / (1024 * 1024);
          if (sizeInMB > 15) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File ${file.path.split('/').last} exceeds 15MB limit'),
              ),
            );
            return;
          }
        }

        setState(() {
          _attachments.addAll(newFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick files: $e')),
      );
    }
  }

  Future<void> _submitFeedback() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a feedback type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FeedbackService.submitFeedback(
        feedbackTypeId: _selectedType!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        voiceNote: _voiceNote,
        attachments: _attachments,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit ${widget.feedbackType}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Dropdown
           DropdownButtonFormField<FeedbackType>(
  value: _selectedType,
  decoration: const InputDecoration(
    labelText: 'Feedback Type',
    border: OutlineInputBorder(),
  ),
  items: _feedbackTypes.map((type) {
    return DropdownMenuItem(
      value: type,
      child: Text(type.name),
    );
  }).toList(),
  onChanged: null, // This makes the dropdown unchangeable
  style: TextStyle(
    color: Colors.black, // Keep text readable even when disabled
    fontSize: 16,
  ),
),
            const SizedBox(height: 16),

            // Title Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Voice Recording Section
           Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voice Note',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_voiceNote == null)
              Expanded(
                child: GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  child: RecordingIndicator(
                    isRecording: _isRecording,
                  ),
                ),
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    onPressed: _playVoiceNote,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _voiceNote = null);
                    },
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  ),
),
            const SizedBox(height: 16),

            // Attachments Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files'),
                          onPressed: _attachments.length >= 3 ? null : _pickFiles,
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ...List.generate(_attachments.length, (index) {
                        final file = _attachments[index];
                        return ListTile(
                          leading: Icon(
                            file.path.toLowerCase().endsWith('.mp4')
                                ? Icons.video_library
                                : Icons.image,
                          ),
                          title: Text(file.path.split('/').last),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _attachments.removeAt(index);
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitFeedback,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303030),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Feedback',
                    style: TextStyle(
                color: Colors.white,  // Add this line
                fontSize: 16,
              ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioPlayer.dispose();
       _audioRecorder.dispose(); // Add this line
    super.dispose();
  }
}