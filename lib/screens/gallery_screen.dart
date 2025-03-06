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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gallery',
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
              ? _buildErrorState(isTablet)
              : _galleries.isEmpty
                  ? _buildEmptyState(isTablet)
                  : RefreshIndicator(
                      onRefresh: _loadGalleries,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 800 : double.infinity,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.all(isTablet ? 24 : 16),
                            itemCount: _galleries.length,
                            itemBuilder: (context, index) {
                              return _buildGalleryCard(_galleries[index], isTablet);
                            },
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildErrorState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 80 : 64,
            color: Colors.red[300],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Failed to load gallery',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
            child: Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          SizedBox(
            height: isTablet ? 56 : 48,
            child: ElevatedButton.icon(
              onPressed: _loadGalleries,
              icon: Icon(
                Icons.refresh,
                size: isTablet ? 24 : 20,
              ),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF303030),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24, 
                  vertical: isTablet ? 16 : 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: isTablet ? 80 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No gallery images found',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Check back later for updates',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTablet ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(FranchiseGallery gallery, bool isTablet) {
    // Format date for display
    String formattedDate = '';
    try {
      final DateTime date = DateTime.parse(gallery.createdAt);
      formattedDate = DateFormat.yMMMMd().format(date);
    } catch (e) {
      formattedDate = gallery.createdAt;
    }

    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 28 : 20),
      elevation: isTablet ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gallery.title,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  gallery.franchiseName,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (gallery.description.isNotEmpty) ...[
                  SizedBox(height: isTablet ? 12 : 8),
                  Text(
                    gallery.description,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Image grid
          _buildImageGrid(gallery.images, context, isTablet),

          // Footer
          Padding(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 16, 
              isTablet ? 12 : 8, 
              isTablet ? 24 : 16, 
              isTablet ? 24 : 16
            ),
            child: Text(
              '${gallery.images.length} photos',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(List<GalleryImage> images, BuildContext context, bool isTablet) {
    // For tablets in landscape, use 4 columns instead of 2
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final crossAxisCount = isTablet && isLandscape ? 4 : 2;
    
    // Adjust the number of preview images based on grid columns
    final maxPreviewImages = isTablet && isLandscape ? 8 : 4;
    final displayImages = images.length > maxPreviewImages 
        ? images.sublist(0, maxPreviewImages) 
        : images;
    final hasMore = images.length > maxPreviewImages;
    final moreCount = images.length - maxPreviewImages;
    final lastDisplayIndex = displayImages.length - 1;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: isTablet ? 4 : 2,
      crossAxisSpacing: isTablet ? 4 : 2,
      children: [
        ...displayImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          bool showMoreOverlay = hasMore && index == lastDisplayIndex;

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
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 16,
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
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: isTablet ? 70 : 56,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.galleryTitle,
              style: TextStyle(fontSize: isTablet ? 20 : 16),
            ),
            Text(
              '${_currentIndex + 1} of ${widget.images.length}',
              style: TextStyle(fontSize: isTablet ? 16 : 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () {
              // Implement share functionality
            },
            iconSize: isTablet ? 28 : 24,
            padding: EdgeInsets.all(isTablet ? 12 : 8),
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
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: isTablet ? 80 : 60,
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: isTablet ? 18 : 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        height: isTablet ? 100 : 80,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Categories chip if any
              if (widget.images[_currentIndex].categories.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                    child: Row(
                      children: widget.images[_currentIndex].categories.map((category) {
                        return Padding(
                          padding: EdgeInsets.only(right: isTablet ? 12 : 8),
                          child: Chip(
                            label: Text(
                              category,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                            backgroundColor: Colors.grey[800],
                            labelStyle: const TextStyle(color: Colors.white),
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 12 : 8,
                              vertical: isTablet ? 4 : 2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              
              // Download button
              SizedBox(
                height: isTablet ? 56 : 48,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadImage,
                  icon: _isDownloading
                      ? SizedBox(
                          width: isTablet ? 20 : 16,
                          height: isTablet ? 20 : 16,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.download,
                          size: isTablet ? 24 : 20,
                        ),
                  label: Text(
                    _isDownloading ? 'Downloading...' : 'Download',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 28 : 20,
                      vertical: isTablet ? 16 : 12,
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
}