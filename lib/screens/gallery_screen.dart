// lib/screens/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_ableaura/models/gallery_image.dart';
import 'package:my_ableaura/services/gallery_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:open_file/open_file.dart';

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
  List<FranchiseGallery> _galleries = [];

  @override
  void initState() {
    super.initState();
    _loadGalleries();
  }

  Future<void> _loadGalleries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final galleries = await GalleryService.getStudentGallery(widget.studentId);
      
      if (!mounted) return;
      
      setState(() {
        _galleries = galleries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _galleries.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadGalleries,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _galleries.length,
                        itemBuilder: (context, index) {
                          return _buildGalleryCard(_galleries[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load gallery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadGalleries,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303030),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No gallery images found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(FranchiseGallery gallery) {
    // Format date for display
    String formattedDate = '';
    try {
      final DateTime date = DateTime.parse(gallery.createdAt);
      formattedDate = DateFormat.yMMMMd().format(date);
    } catch (e) {
      formattedDate = gallery.createdAt;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gallery.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gallery.franchiseName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (gallery.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    gallery.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Image grid
          _buildImageGrid(gallery.images, context),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              '${gallery.images.length} photos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<GalleryImage> images, BuildContext context) {
    // Limit preview to 4 images, with a "View All" overlay if more
    final displayImages = images.length > 4 ? images.sublist(0, 4) : images;
    final hasMore = images.length > 4;
    final moreCount = images.length - 4;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: [
        ...displayImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          bool showMoreOverlay = hasMore && index == 3;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenGallery(
                    images: images,
                    initialIndex: index,
                    galleryTitle: _galleries.firstWhere(
                      (gallery) => gallery.images.contains(image),
                      orElse: () => FranchiseGallery(
                        title: '',
                        description: '',
                        franchiseId: 0,
                        franchiseName: '',
                        createdAt: '',
                        images: [],
                        imageCount: 0,
                      ),
                    ).title,
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: image.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                    ),
                  ),
                ),
                if (showMoreOverlay)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Text(
                        '+$moreCount more',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<GalleryImage> images;
  final int initialIndex;
  final String galleryTitle;

  const FullScreenGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.galleryTitle,
  }) : super(key: key);

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isDownloading = false;

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

  Future<void> _downloadImage() async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
    });
    
    try {
      final currentImage = widget.images[_currentIndex];
      
      // Show download started snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Downloading image...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      
      final filePath = await GalleryService.downloadGalleryPhoto(currentImage.imageUrl);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 16),
              const Expanded(child: Text('Image saved')),
              TextButton(
                onPressed: () async {
                  try {
                    await OpenFile.open(filePath);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not open image: $e')),
                    );
                  }
                },
                child: const Text(
                  'VIEW',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.galleryTitle,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${_currentIndex + 1} of ${widget.images.length}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: widget.images[index].imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              errorWidget: (context, url, error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        height: 80,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Categories chip if any
              if (widget.images[_currentIndex].categories.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: widget.images[_currentIndex].categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(category),
                            backgroundColor: Colors.grey[800],
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              
              // Download button
              ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadImage,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Downloading...' : 'Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}