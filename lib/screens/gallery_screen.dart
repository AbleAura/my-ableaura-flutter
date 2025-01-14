import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/gallery.dart';
import '../../services/student_service.dart';
import 'package:intl/intl.dart';

class GalleryScreen extends StatefulWidget {
  final int studentId;
  final String studentName;

  const GalleryScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String? _error;
  List<GalleryPhoto> _photos = [];
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final response = await StudentService.getGalleryPhotos(widget.studentId);
      if (!mounted) return;
      
      setState(() {
        _photos = response.photos;
        _hasMore = response.currentPage < response.lastPage;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Something went wrong. Please try again.';
      
      if (e.toString().contains('No query results')) {
        errorMessage = 'No images found!';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Unable to load gallery at the moment';
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.studentName}\'s Gallery'),
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
                      Icon(
                        _error!.contains('No images') 
                            ? Icons.photo_library_outlined 
                            : Icons.error_outline,
                        size: 64,
                        color: _error!.contains('No images') 
                            ? Colors.grey 
                            : Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _error!.contains('No images') 
                              ? Colors.grey[600] 
                              : Colors.red[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!_error!.contains('No images'))
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF303030),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _loadPhotos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPhotos,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _FullScreenImage(
                                photo: photo,
                                allPhotos: _photos,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: photo.url,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photo.url,
                                fit: BoxFit.cover,
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
                                  return const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
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

// Full screen image widget within the same file
class _FullScreenImage extends StatefulWidget {
  final GalleryPhoto photo;
  final List<GalleryPhoto> allPhotos;
  final int initialIndex;

  const _FullScreenImage({
    required this.photo,
    required this.allPhotos,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<_FullScreenImage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

 Future<bool> _checkAndRequestStoragePermission() async {
  try {
    // First check current status
    PermissionStatus storageStatus = await Permission.storage.status;
    PermissionStatus photosStatus = await Permission.photos.status;
    
    print('Initial status - Storage: $storageStatus, Photos: $photosStatus'); // Debug log

    // If already granted, return true
    if (storageStatus.isGranted || photosStatus.isGranted) {
      return true;
    }

    // Show explanation dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text('We need storage permission to save images to your device. Please grant the permission in the next dialog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
            },
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    ) ?? false;

    if (!shouldRequest) return false;

    // Directly request both permissions
    print('Requesting permissions...'); // Debug log
    
    // Request storage permission first
    storageStatus = await Permission.storage.request();
    print('Storage permission after request: $storageStatus'); // Debug log

    // For Android 13+, also request photos permission
    photosStatus = await Permission.photos.request();
    print('Photos permission after request: $photosStatus'); // Debug log

    // Check if either permission was granted
    if (storageStatus.isGranted || photosStatus.isGranted) {
      return true;
    }

    // Handle permanently denied case
    if (storageStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
      if (!mounted) return false;

      final openSettings = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Storage permission is permanently denied. Please enable it in app settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('OPEN SETTINGS'),
            ),
          ],
        ),
      ) ?? false;

      if (openSettings) {
        await openAppSettings();
        // Re-check permission after returning from settings
        final finalStatus = await Permission.storage.status;
        return finalStatus.isGranted;
      }
    }

    return false;
  } catch (e) {
    print('Error in permission request: $e'); // Debug log
    return false;

    
  }
}

Future<bool> _requestPermissions() async {
  // Request both storage and photos permissions
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.photos,
  ].request();

  // Check if both permissions are granted
  return statuses[Permission.storage]!.isGranted || 
         statuses[Permission.photos]!.isGranted;
}

Future<bool> _requestStoragePermission() async {
  final status = await Permission.storage.status;
  
  if (status.isGranted) {
    return true;
  }

  if (status.isPermanentlyDenied) {
    // Show dialog to open settings
    final openSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'Storage permission is required to save images to your device. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OPEN SETTINGS'),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      await openAppSettings();
      // Check if permission was granted after returning from settings
      final newStatus = await Permission.storage.status;
      return newStatus.isGranted;
    }
    return false;
  }

  // Request permission
  final result = await Permission.storage.request();
  return result.isGranted;
}

Future<void> _downloadImage() async {
  try {
    // Check permissions first
    final hasPermission = await _checkAndRequestStoragePermission();
    
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save images'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();  // Clear any existing snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
            SizedBox(width: 16),
            Text('Downloading image...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Download the image
    final savedFilePath = await StudentService.downloadGalleryPhoto(
      widget.allPhotos[_currentIndex].url,
    );

    if (!mounted) return;

    // Clear the loading snackbar
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show success message with Open button
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 16),
            const Expanded(
              child: Text('Image saved successfully'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await OpenFile.open(savedFilePath);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not open the image: ${e.toString()}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text(
                'OPEN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    print('Download error: $e');  // Debug log
    if (!mounted) return;
    
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text('Failed to download image: ${e.toString()}')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.allPhotos.length}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          Text(
            DateFormat('MMMM d, y').format(widget.allPhotos[_currentIndex].date),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.allPhotos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final photo = widget.allPhotos[index];
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Hero(
                    tag: photo.url,
                    child: Image.network(
                      photo.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Download button section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: _downloadImage,
                icon: const Icon(Icons.download),
                label: const Text('Download Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}