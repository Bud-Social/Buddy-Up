import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/page_loader.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  int _quantity = 1;
  int _mediaIndex = 0;
  String? _tier;

  bool _feedbackRequested = false;
  bool _feedbackLoading = false;
  bool _fbSubmitting = false;
  int _fbRating = 0;
  final Set<String> _fbTags = {};
  final TextEditingController _fbNote = TextEditingController();
  Map<String, dynamic>? _ownFeedback;
  Map<String, dynamic>? _aggregate;
  String? _fbError;

  @override
  void dispose() {
    _fbNote.dispose();
    super.dispose();
  }

  bool _isPast(MarketplaceEvent event) {
    final end = DateTime.tryParse(event.endDatetime);
    return end != null && end.isBefore(DateTime.now());
  }

  void _ensureFeedback(MarketplaceEvent event) {
    if (_feedbackRequested) return;
    _feedbackRequested = true;
    Future.microtask(() async {
      if (!mounted) return;
      setState(() => _feedbackLoading = true);
      try {
        final raw = await ref
            .read(marketplaceRepositoryProvider)
            .getEventFeedback(event.id);
        final data = raw is Map ? raw['data'] : null;
        if (!mounted) return;
        setState(() {
          if (data is Map && data['rating'] is num) {
            _ownFeedback = Map<String, dynamic>.from(data);
            _fbRating = (data['rating'] as num).toInt();
            _fbNote.text = '${data['note'] ?? ''}';
            final tags = data['tags'];
            if (tags is List) {
              _fbTags.addAll(tags.map((t) => '$t'));
            }
          } else if (data is Map && data['count'] != null) {
            _aggregate = Map<String, dynamic>.from(data);
          }
          _feedbackLoading = false;
        });
      } catch (_) {
        if (mounted) setState(() => _feedbackLoading = false);
      }
    });
  }

  Future<void> _submitFeedback(String eventId) async {
    if (_fbRating == 0) {
      setState(() => _fbError = 'Pick a rating first.');
      return;
    }
    setState(() {
      _fbSubmitting = true;
      _fbError = null;
    });
    try {
      final raw = await ref
          .read(marketplaceRepositoryProvider)
          .submitEventFeedback(eventId, {
        'rating': _fbRating,
        'tags': _fbTags.toList(),
        'note': _fbNote.text.trim(),
      });
      final data = raw is Map ? raw['data'] : null;
      if (!mounted) return;
      setState(() {
        _ownFeedback = data is Map
            ? Map<String, dynamic>.from(data)
            : {
                'rating': _fbRating,
                'tags': _fbTags.toList(),
                'note': _fbNote.text.trim(),
              };
        _fbSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks — feedback sent.')),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _fbSubmitting = false;
          _fbError = 'Could not submit feedback. Your ticket gates eligibility.';
        });
      }
    }
  }

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
        if (event.isRegistered && _isPast(event)) _ensureFeedback(event);
        return Scaffold(
          appBar: AppBar(title: Text(event.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel
                if (media.isNotEmpty) _buildCarousel(media, hasCarousel, event),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        event.creatorData.avatarUrl,
                      ),
                      backgroundColor: BuddyColors.surfaceRaised,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                event.creatorData.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (event.creatorData.verificationStatus ==
                                  'verified') ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.badgeCheck,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ],
                            ],
                          ),
                          if (event.shopData != null)
                            Text(
                              'by ${event.shopData!.name}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _infoRow(LucideIcons.video, _eventTypeLabel(event.eventType)),
                if (event.gymData != null) ...[
                  const SizedBox(height: 4),
                  _infoRow(LucideIcons.dumbbell, event.gymData!.name),
                ],
                const SizedBox(height: 4),
                _infoRow(
                  LucideIcons.calendarDays,
                  _formatDate(event.startDatetime),
                ),
                const SizedBox(height: 4),
                _infoRow(LucideIcons.clock, _formatTime(event.startDatetime)),
                if (event.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _infoRow(LucideIcons.mapPin, event.location),
                ],
                if (event.recurrence != 'none') ...[
                  const SizedBox(height: 4),
                  _infoRow(
                    LucideIcons.repeat2,
                    _recurrenceLabel(event.recurrence),
                  ),
                ],
                if (event.earlyBirdEnabled) ...[
                  const SizedBox(height: 4),
                  _infoRow(LucideIcons.zap, _earlyBirdLabel(event)),
                ],
                const SizedBox(height: 16),
                _buildCapacityBar(event),
                if (event.ticketTiers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Ticket Tiers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...event.ticketTiers.map((t) {
                    final name = (t['name'] ?? '') as String;
                    final price = t['price_artifacts'];
                    final selected =
                        _tier == name ||
                        (_tier == null && t == event.ticketTiers.first);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _tier = name),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BuddyColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? BuddyColors.green
                                  : BuddyColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (price is Map && price.isNotEmpty)
                                Text(
                                  price.entries
                                      .map((e) => '${e.value} ${e.key}')
                                      .join(', '),
                                  style: const TextStyle(
                                    color: BuddyColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                const Text(
                                  'Free',
                                  style: TextStyle(
                                    color: BuddyColors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 16),
                Text(event.description, style: const TextStyle(height: 1.5)),
                if (event.agenda.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Agenda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...event.agenda.map(
                    (item) => Padding(
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: BuddyColors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['title'] ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if ((item['description'] ?? '').isNotEmpty)
                                  Text(
                                    '${item['description']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (event.cancellationPolicy.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _infoRow(
                    LucideIcons.fileWarning,
                    'Cancellation: ${event.cancellationPolicy}',
                  ),
                ],
                if (event.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: event.tags
                        .map(
                          (t) => Chip(
                            label: Text(t),
                            backgroundColor: BuddyColors.surfaceRaised,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (event.isRegistered && _isPast(event)) ...[
                  const SizedBox(height: 16),
                  _buildFeedbackCard(event),
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
                        icon: LucideIcons.minus,
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: LucideIcons.plus,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (ctx) {
                      final soldOut =
                          event.capacity > 0 &&
                          event.attendeeCount >= event.capacity;
                      return BuddyButton(
                        label: event.isRegistered
                            ? 'My Ticket'
                            : soldOut
                            ? 'Sold Out'
                            : 'Add to Cart',
                        onPressed: event.isRegistered
                            ? () => context.push('/marketplace/tickets')
                            : soldOut
                            ? null
                            : () {
                                ref
                                    .read(cartProvider.notifier)
                                    .addToCart(
                                      'event_ticket',
                                      {'event_id': widget.eventId},
                                      quantity: _quantity,
                                      tier: _tier,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Added to cart'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                _quantity = 1;
                              },
                      );
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

  Widget _buildFeedbackCard(MarketplaceEvent event) {
    final hasOwn = _ownFeedback != null || _fbRating > 0;
    final aggregateCount = _aggregate?['count'];
    final aggregateAverage = _aggregate?['average'];
    const tagOptions = [
      'vibes',
      'coaching',
      'audio',
      'equipment',
      'instructor',
      'value',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.star, size: 16, color: BuddyColors.gold),
              SizedBox(width: 8),
              Text(
                'How did this event land?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_feedbackLoading)
            Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading feedback…',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          else if (hasOwn) ...[
            Text(
              'Your rating: ${'★' * _fbRating}${'☆' * (5 - _fbRating)}'
              ' · ${(_ownFeedback?['note'] ?? _fbNote.text).toString().isEmpty ? '—' : (_ownFeedback?['note'] ?? _fbNote.text)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (aggregateCount is num)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '$aggregateCount attendee${aggregateCount == 1 ? '' : 's'} '
                  'rated this event'
                  '${aggregateAverage != null ? ' — avg $aggregateAverage★' : ''}.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
          ] else ...[
            Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => setState(() => _fbRating = star),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        star <= _fbRating
                            ? Icons.star
                            : Icons.star_border,
                        size: 24,
                        color: star <= _fbRating
                            ? BuddyColors.gold
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in tagOptions)
                  FilterChip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    selected: _fbTags.contains(tag),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.15),
                    onSelected: (active) => setState(() {
                      if (active) {
                        _fbTags.add(tag);
                      } else {
                        _fbTags.remove(tag);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fbNote,
              maxLines: 2,
              maxLength: 500,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Coach energy, venue, sound — what worked?',
                border: OutlineInputBorder(),
                isDense: true,
                counterText: '',
              ),
            ),
            if (_fbError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _fbError!,
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _fbSubmitting
                    ? null
                    : () => _submitFeedback(event.id),
                child: _fbSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send feedback'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCarousel(
    List<_MediaItem> media,
    bool hasCarousel,
    MarketplaceEvent event,
  ) {
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
                        event.coverImageUrl.isNotEmpty
                            ? event.coverImageUrl
                            : media[_mediaIndex].url,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 220,
                          color: BuddyColors.surfaceRaised,
                          child: Icon(
                            LucideIcons.video,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          LucideIcons.play,
                          color: Colors.white,
                          size: 32,
                        ),
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
                      child: Icon(
                        LucideIcons.calendarDays,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                    _mediaIndex = _mediaIndex == 0
                        ? media.length - 1
                        : _mediaIndex - 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      LucideIcons.chevronLeft,
                      color: Colors.white,
                      size: 20,
                    ),
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
                    _mediaIndex = _mediaIndex == media.length - 1
                        ? 0
                        : _mediaIndex + 1;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      LucideIcons.chevronRight,
                      color: Colors.white,
                      size: 20,
                    ),
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
                    Icon(LucideIcons.video, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Video',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
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
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
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
            Text(
              'Capacity: ${event.attendeeCount}/${event.capacity}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            if (spots != null)
              Text(
                '$spots spots left',
                style: const TextStyle(
                  color: BuddyColors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: BuddyColors.surfaceRaised,
            valueColor: const AlwaysStoppedAnimation<Color>(BuddyColors.green),
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
  return price.isEmpty
      ? 'Early bird pricing$deadlineText'
      : 'Early bird: $price$deadlineText';
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
        color: onPressed == null
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _MediaItem {
  final String type;
  final String url;
  _MediaItem(this.type, this.url);
}
