import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _quantity = 1;
  int _mediaIndex = 0;

  List<_MediaItem> _buildMediaList(MarketplaceEvent event) {
    final list = <_MediaItem>[];
    if (event.media.isNotEmpty) {
      for (final m in event.media) {
        if (m.url.isNotEmpty) list.add(_MediaItem(m.mediaType, m.url));
      }
    }
    if (event.galleryUrls.isNotEmpty) {
      for (final url in event.galleryUrls) {
        if (!list.any((e) => e.url == url)) list.add(_MediaItem('image', url));
      }
    }
    if (event.coverImageUrl.isNotEmpty &&
        !list.any((e) => e.url == event.coverImageUrl)) {
      list.insert(0, _MediaItem('image', event.coverImageUrl));
    }
    if (event.promoVideoUrl.isNotEmpty &&
        !list.any((e) => e.url == event.promoVideoUrl)) {
      list.add(_MediaItem('video', event.promoVideoUrl));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    return eventAsync.when(
      data: (event) {
        final media = _buildMediaList(event);
        final hasCarousel = media.length > 1;
        return Scaffold(
          appBar: AppBar(title: Text(event.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel
                if (media.isNotEmpty)
                  _buildCarousel(media, hasCarousel, event),
                const SizedBox(height: 16),
                Text(event.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(event.creatorData.avatarUrl),
                      backgroundColor: BuddyColors.surfaceRaised,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(event.creatorData.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (event.creatorData.verificationStatus == 'verified') ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, size: 14, color: Colors.blue),
                              ],
                            ],
                          ),
                          if (event.shopData != null)
                            Text('by ${event.shopData!.name}',
                                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow(Icons.videocam, _eventTypeLabel(event.eventType)),
                if (event.gymData != null) ...[
                  const SizedBox(height: 4),
                  _infoRow(Icons.fitness_center, event.gymData!.name),
                ],
                const SizedBox(height: 4),
                _infoRow(Icons.calendar_today, _formatDate(event.startDatetime)),
                const SizedBox(height: 4),
                _infoRow(Icons.access_time, _formatTime(event.startDatetime)),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _infoRow(Icons.location_on, event.location),
                ],
                if (event.recurrence != 'none') ...[
                  const SizedBox(height: 4),
                  _infoRow(Icons.repeat, _recurrenceLabel(event.recurrence)),
                ],
                if (event.earlyBirdEnabled) ...[
                  const SizedBox(height: 4),
                  _infoRow(Icons.flash_on, _earlyBirdLabel(event)),
                ],
                const SizedBox(height: 16),
                _buildCapacityBar(event),
                const SizedBox(height: 16),
                Text(event.description, style: const TextStyle(height: 1.5)),
                if (event.agenda.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Agenda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...event.agenda.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: BuddyColors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${item['time'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold,
                                  color: BuddyColors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item['title'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              if ((item['description'] ?? '').isNotEmpty)
                                Text('${item['description']}',
                                    style: const TextStyle(
                                        fontSize: 12, color: BuddyColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (event.cancellationPolicy.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _infoRow(Icons.assignment_late, 'Cancellation: ${event.cancellationPolicy}'),
                ],
                if (event.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: event.tags
                        .map((t) => Chip(
                              label: Text(t),
                              backgroundColor: BuddyColors.surfaceRaised,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: BuddyColors.surface,
              border: Border(top: BorderSide(color: BuddyColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: BuddyColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text('$_quantity',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BuddyButton(
                    label: event.isRegistered ? 'In Cart' : 'Add to Cart',
                    onPressed: event.isRegistered
                        ? null
                        : () {
                            ref.read(cartProvider.notifier).addToCart(
                              'event_ticket',
                              {'event_id': widget.eventId},
                              quantity: _quantity,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Added to cart'),
                                  duration: Duration(seconds: 1)),
                            );
                            _quantity = 1;
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: PageLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }

  Widget _buildCarousel(List<_MediaItem> media, bool hasCarousel, MarketplaceEvent event) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: media[_mediaIndex].type == 'video'
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        event.coverImageUrl.isNotEmpty ? event.coverImageUrl : media[_mediaIndex].url,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 220,
                          color: BuddyColors.surfaceRaised,
                          child: const Icon(Icons.videocam, size: 48, color: BuddyColors.textSecondary),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                      ),
                    ],
                  )
                : Image.network(
                    media[_mediaIndex].url,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 220,
                      color: BuddyColors.surfaceRaised,
                      child: const Icon(Icons.event, size: 48, color: BuddyColors.textSecondary),
                    ),
                  ),
          ),
          // Gradient overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
          // Navigation arrows
          if (hasCarousel) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _mediaIndex = _mediaIndex == 0 ? media.length - 1 : _mediaIndex - 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _mediaIndex = _mediaIndex == media.length - 1 ? 0 : _mediaIndex + 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
          ],
          // Dots indicator
          if (hasCarousel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(media.length, (i) {
                  return Container(
                    width: i == _mediaIndex ? 16 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _mediaIndex ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          // Video tag
          if (media[_mediaIndex].type == 'video')
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Video', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: BuddyColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(text,
              style: const TextStyle(color: BuddyColors.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildCapacityBar(MarketplaceEvent event) {
    final pct = event.capacity > 0 ? event.attendeeCount / event.capacity : 0.0;
    final spots = event.spotsRemaining;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Capacity: ${event.attendeeCount}/${event.capacity}',
                style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 13)),
            if (spots != null)
              Text('$spots spots left',
                  style: const TextStyle(
                      color: BuddyColors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: BuddyColors.surfaceRaised,
            valueColor:
                const AlwaysStoppedAnimation<Color>(BuddyColors.green),
          ),
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

String _eventTypeLabel(String type) {
  switch (type) {
    case 'online':
      return 'Virtual';
    case 'in_person':
      return 'In Person';
    case 'hybrid':
      return 'Hybrid';
    default:
      return type.replaceAll('_', ' ');
  }
}

String _recurrenceLabel(String recurrence) {
  switch (recurrence) {
    case 'daily':
      return 'Repeats daily';
    case 'weekly':
      return 'Repeats weekly';
    case 'monthly':
      return 'Repeats monthly';
    default:
      return 'One-time event';
  }
}

String _earlyBirdLabel(MarketplaceEvent event) {
  final deadline = event.earlyBirdDeadline;
  final deadlineText = deadline == null || deadline.isEmpty
      ? ''
      : ' (until ${_shortDate(deadline)})';
  final price = event.earlyBirdPriceArtifacts.entries
      .map((e) => '${e.value} ${e.key}s')
      .join(', ');
  return price.isEmpty ? 'Early bird pricing$deadlineText' : 'Early bird: $price$deadlineText';
}

String _shortDate(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${dt.month}/${dt.day}';
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QtyButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: onPressed == null ? BuddyColors.textSecondary : BuddyColors.textPrimary,
      ),
    );
  }
}

class _MediaItem {
  final String type;
  final String url;
  _MediaItem(this.type, this.url);
}
