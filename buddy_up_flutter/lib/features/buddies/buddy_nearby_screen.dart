import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/toast.dart';
import '../../shared/navigation/app_nav.dart';
import 'buddy_nearby_provider.dart';

const _intents = ['walk', 'run', 'gym', 'hike', 'live_cohost', 'trainer', 'coach', 'book_club', 'friend', 'other'];
const _modes = ['virtual', 'hybrid', 'in_person', 'neighbourhood'];
const _goalOptions = ['weight_loss', 'muscle_gain', 'endurance', 'get_faster', 'stay_consistent', 'learn_sport', 'rehabilitation', 'have_fun'];
const _visibilities = ['public', 'buddies', 'hidden'];

class BuddyNearbyScreen extends ConsumerStatefulWidget {
  const BuddyNearbyScreen({super.key});

  @override
  ConsumerState<BuddyNearbyScreen> createState() => _BuddyNearbyScreenState();
}

class _BuddyNearbyScreenState extends ConsumerState<BuddyNearbyScreen> {
  SearchProfile? _mine;
  bool _editing = false;
  bool _saving = false;
  bool _uploading = false;
  final _bio = TextEditingController();
  final _customIntent = TextEditingController();
  final _dob = TextEditingController();
  final _pace = TextEditingController();
  final _neighbourhood = TextEditingController();
  List<String> _goals = [];
  List<String> _photos = [];
  String _visibility = 'public';
  bool _incognito = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(buddyNearbyProvider.notifier).load());
    _loadMine();
  }

  Future<void> _loadMine() async {
    try {
      final raw = await ref.read(profileRepositoryProvider).getSearchProfile();
      final data = raw['data'];
      if (data is Map<String, dynamic> && mounted) {
        final sp = SearchProfile.fromJson(data);
        setState(() {
          _mine = sp;
          _bio.text = sp.bio;
          _customIntent.text = sp.customIntent;
          _goals = [...sp.goals];
          _photos = [...sp.photos];
          _pace.text = '';
          _neighbourhood.text = '';
          _visibility = sp.visibility;
          _incognito = sp.incognito;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _bio.dispose();
    _customIntent.dispose();
    _dob.dispose();
    _pace.dispose();
    _neighbourhood.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    final notifier = ref.read(buddyNearbyProvider.notifier);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) showToast(context, 'Turn on location services to find buddies near you.', type: ToastType.error);
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          showToast(context, 'Location blocked — allow it in system settings.', type: ToastType.error);
        }
        return;
      }
      if (perm == LocationPermission.denied) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      notifier.setCoords(pos.latitude, pos.longitude);
      await notifier.persistSearchProfile();
      notifier.load();
    } catch (_) {
      if (mounted) showToast(context, 'Could not get your location. Try again.', type: ToastType.error);
    }
  }

  Future<void> _addPhotos() async {
    final remaining = 4 - _photos.length;
    if (remaining <= 0) {
      showToast(context, 'Up to 4 search profile photos.', type: ToastType.error);
      return;
    }
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isEmpty) return;
    setState(() => _uploading = true);
    try {
      final dio = ApiClient().dio;
      for (final x in picked.take(remaining)) {
        final form = FormData.fromMap({
          'file': await MultipartFile.fromFile(x.path, filename: x.name),
        });
        final res = await dio.post('/messaging/upload/', data: form);
        final url = res.data?['data']?['url'] as String?;
        if (url != null && url.isNotEmpty) {
          setState(() => _photos = [..._photos, url].take(4).toList());
        }
      }
    } catch (_) {
      if (mounted) showToast(context, 'Photo upload failed.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save({bool? looking}) async {
    final notifier = ref.read(buddyNearbyProvider.notifier);
    final current = ref.read(buddyNearbyProvider);
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        'intents': current.intent != null ? [current.intent] : [],
        'bio': _bio.text.trim(),
        'goals': _goals,
        'photos': _photos,
        'pace': _pace.text.trim(),
        'neighbourhood': _neighbourhood.text.trim(),
        'visibility': _visibility,
        'incognito': _incognito,
      };
      if (current.intent == 'other') body['custom_intent'] = _customIntent.text.trim();
      final mode = current.mode;
      if (mode != null) body['modes'] = [mode];
      if (_dob.text.trim().isNotEmpty) body['dob'] = _dob.text.trim();
      if (looking != null) body['available_now'] = looking;
      final lat = current.lat;
      if (lat != null) body['latitude'] = lat;
      final lng = current.lng;
      if (lng != null) body['longitude'] = lng;
      final raw = await ref.read(profileRepositoryProvider).updateSearchProfile(body);
      final data = raw['data'];
      if (data is Map<String, dynamic> && mounted) {
        final sp = SearchProfile.fromJson(data);
        setState(() => _mine = sp);
        final matches = data['match_count'];
        if (looking == true && matches is int && matches > 0) {
          showToast(context, '$matches buddie(s) nearby looking too 👀', type: ToastType.success);
        } else {
          showToast(context, 'Search profile saved.', type: ToastType.success);
        }
      }
      notifier.load();
    } catch (_) {
      if (mounted) showToast(context, 'Could not save search profile.', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _sendRequest(String username) async {
    try {
      await ref.read(profileRepositoryProvider).sendBuddyRequest(username);
      if (mounted) showToast(context, 'Buddy request sent!', type: ToastType.success);
    } catch (_) {
      if (mounted) showToast(context, 'Failed.', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buddyNearbyProvider);
    final notifier = ref.read(buddyNearbyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu',
          onPressed: () => AppNav.open(context),
        ),
        title: const Text('Find a buddy'),
        actions: [
          TextButton(
            onPressed: () => _save(looking: !(_mine?.availableNow == true)),
            child: Text(
              _mine?.availableNow == true ? 'Looking ✓' : 'I’m looking now',
              style: const TextStyle(color: BuddyColors.green),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('I’m looking for', style: TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final i in _intents)
                      ChoiceChip(
                        label: Text(i.replaceAll('_', ' ')),
                        selected: state.intent == i,
                        onSelected: (_) {
                          if (state.intent == i) {
                            notifier.load(clearIntent: true);
                          } else {
                            notifier.load(intent: i);
                          }
                        },
                        selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: state.intent == i ? BuddyColors.green : BuddyColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                if (state.intent == 'other')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: _customIntent,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Describe what you’re looking for…',
                        hintStyle: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in _modes)
                      ChoiceChip(
                        label: Text(m.replaceAll('_', ' ')),
                        selected: state.mode == m,
                        onSelected: (_) {
                          if (state.mode == m) {
                            notifier.load(clearMode: true);
                          } else {
                            notifier.load(mode: m);
                          }
                        },
                        selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: state.mode == m ? BuddyColors.green : BuddyColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ChoiceChip(
                      label: const Text('Available now'),
                      selected: state.nowOnly,
                      onSelected: (v) {
                        notifier.setNowOnly(v);
                        notifier.load();
                      },
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: state.nowOnly ? BuddyColors.green : BuddyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    ActionChip(
                      avatar: Icon(
                        Icons.near_me,
                        size: 14,
                        color: state.lat != null ? BuddyColors.green : BuddyColors.textSecondary,
                      ),
                      label: Text(state.lat != null ? 'Near me ✓' : 'Near me'),
                      onPressed: () {
                        if (state.lat != null) {
                          notifier.setCoords(null, null);
                          notifier.load();
                        } else {
                          _locate();
                        }
                      },
                    ),
                    if (state.lat != null)
                      DropdownButton<double?>(
                        value: state.radiusKm,
                        hint: const Text('Auto (5–10 km)',
                            style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Auto (5–10 km)')),
                          DropdownMenuItem(value: 5, child: Text('5 km')),
                          DropdownMenuItem(value: 10, child: Text('10 km')),
                        ],
                        onChanged: (v) {
                          notifier.setRadius(v);
                          notifier.load();
                        },
                      ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  child: Text(_editing ? 'Hide my search profile setup' : 'Set up my search profile${_mine != null && _mine!.ageBand.isNotEmpty ? ' · ${_mine!.ageBand}' : ''}'),
                ),
                if (_editing) _setupEditor(),
              ],
            ),
          ),
          if (state.lat != null && state.geo != null && state.geo!.auto && state.geo!.message != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BuddyColors.green.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, size: 15, color: BuddyColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby: ${state.geo!.radiusKm.toStringAsFixed(0)} km · ${state.geo!.density == 'dense' ? 'lots around you' : 'fewer around you'}',
                          style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(state.geo!.message!, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const PageLoader(fullScreen: false)
                : state.error != null
                    ? ErrorView(message: state.error!, onRetry: () => notifier.load())
                    : state.buddies.isEmpty
                        ? const Center(
                            child: Text('No buddies found — try another intent or widen the search.',
                                style: TextStyle(color: BuddyColors.textSecondary)),
                          )
                        : ListView.builder(
                            itemCount: state.buddies.length,
                            itemBuilder: (_, i) => _buddyTile(state.buddies[i]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _setupEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _bio,
          maxLength: 140,
          maxLines: 2,
          style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Find-buddy bio — e.g. easy 5k at 6am, all paces welcome…',
            hintStyle: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        const Text('What I want to achieve (up to 5)', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in _goalOptions)
              ChoiceChip(
                label: Text(g.replaceAll('_', ' ')),
                selected: _goals.contains(g),
                onSelected: (_) {
                  setState(() {
                    if (_goals.contains(g)) {
                      _goals = _goals.where((x) => x != g).toList();
                    } else if (_goals.length < 5) {
                      _goals = [..._goals, g];
                    }
                  });
                },
                selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: _goals.contains(g) ? BuddyColors.green : BuddyColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dob,
                style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Birth date (for age band)',
                  hintText: 'YYYY-MM-DD',
                  hintStyle: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _pace,
                style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Pace',
                  hintText: 'Easy / steady / brisk',
                  hintStyle: TextStyle(color: BuddyColors.textSecondary, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photos.isNotEmpty)
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(_photos[i], width: 64, height: 64, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _photos = _photos.where((u) => u != _photos[i]).toList()),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: _uploading ? null : _addPhotos,
          icon: _uploading
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.camera_alt, size: 14),
          label: Text('Search photos (${_photos.length}/4)'),
        ),
        Row(
          children: [
            const Text('Visible to ', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
            DropdownButton<String>(
              value: _visibility,
              underline: const SizedBox.shrink(),
              items: [
                for (final v in _visibilities)
                  DropdownMenuItem(value: v, child: Text(v == 'buddies' ? 'Buddies only' : v[0].toUpperCase() + v.substring(1))),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _visibility = v);
              },
            ),
            const SizedBox(width: 12),
            const Text('Incognito', style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
            Switch(
              value: _incognito,
              onChanged: (v) => setState(() => _incognito = v),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : () => _save(),
            child: Text(_saving ? 'Saving…' : 'Save search profile'),
          ),
        ),
      ],
    );
  }

  Widget _buddyTile(NearbyBuddy b) {
    final p = b.profile;
    final name = (p['display_name'] ?? p['username'] ?? '') as String;
    final username = (p['username'] ?? '') as String;
    final avatar = (b.photos.isNotEmpty ? b.photos.first : p['avatar_url']) as String?;
    final prefs = p['preferences'];
    final workouts = prefs is Map
        ? ((prefs['preferred_workouts'] as List?) ?? []).map((e) => e.toString()).toList()
        : <String>[];
    final wants = b.customIntent.isNotEmpty
        ? b.customIntent
        : b.intents.map((e) => e.replaceAll('_', ' ')).join(', ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: BuddyColors.surface,
      child: ListTile(
        leading: Avatar(src: avatar, alt: name, size: AvatarSize.md),
        title: Row(
          children: [
            Flexible(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: BuddyColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            if (b.availableNow) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: BuddyColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('now',
                    style: TextStyle(color: BuddyColors.green, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
            if (b.ageBand.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(b.ageBand, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@$username', style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
            if (wants.isNotEmpty) Text('Wants: $wants', style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 12)),
            if (b.bio.isNotEmpty)
              Text(b.bio, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 12)),
            Text(b.explanation, style: const TextStyle(color: BuddyColors.green, fontSize: 12)),
            if (workouts.isNotEmpty)
              Text(workouts.map((e) => e.replaceAll('_', ' ')).join(' · '),
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BuddyColors.textSecondary, fontSize: 11)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.person_add, color: BuddyColors.green),
          onPressed: () => _sendRequest(username),
        ),
        onTap: () => context.push('/$username'),
      ),
    );
  }
}
