import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';

class MediaGallery extends StatelessWidget {
  final List<String> urls;
  final List<String>? types;

  const MediaGallery({super.key, required this.urls, this.types});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    if (urls.length == 1) return _buildSingle(context, urls.first);
    if (urls.length == 2) return _buildPair(context);
    if (urls.length == 3) return _buildTriplet(context);
    return _buildGrid(context);
  }

  Widget _buildSingle(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _buildMedia(url, context, height: 300),
    );
  }

  Widget _buildPair(BuildContext context) {
    return Row(
      children: urls.map((url) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            left: urls.indexOf(url) == 1 ? 4 : 0,
            right: urls.indexOf(url) == 0 ? 4 : 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMedia(url, context, height: 200),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTriplet(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildMedia(urls[0], context, height: 200),
        ),
        const SizedBox(height: 4),
        Row(
          children: urls.sublist(1).map((url) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: urls.indexOf(url) == 2 ? 4 : 0,
                right: urls.indexOf(url) == 1 ? 4 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildMedia(url, context, height: 120),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: urls.take(9).map((url) {
        final index = urls.indexOf(url);
        return GestureDetector(
          onTap: () => _openLightbox(context, index),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMedia(url, context, height: 120),
              ),
              if (index == 8 && urls.length > 9)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '+${urls.length - 9}',
                      style: const TextStyle(
                        color: BuddyColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedia(String url, BuildContext context, {double? height}) {
    final isVideo = url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.webm');
    return SizedBox(
      height: height,
      width: double.infinity,
      child: isVideo
          ? _videoPlaceholder(url)
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
              errorWidget: (_, _, _) => Container(
                color: BuddyColors.surfaceRaised,
                child: const Icon(Icons.broken_image, color: BuddyColors.textSecondary),
              ),
            ),
    );
  }

  Widget _videoPlaceholder(String url) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _) => Container(color: BuddyColors.surfaceRaised),
          errorWidget: (_, _, _) => Container(color: BuddyColors.surfaceRaised),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  void _openLightbox(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => _LightboxPage(urls: urls, initialIndex: index),
    );
  }
}

class _LightboxPage extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _LightboxPage({required this.urls, required this.initialIndex});

  @override
  State<_LightboxPage> createState() => _LightboxPageState();
}

class _LightboxPageState extends State<_LightboxPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.urls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemBuilder: (_, i) {
            return InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const CircularProgressIndicator(),
                  errorWidget: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
