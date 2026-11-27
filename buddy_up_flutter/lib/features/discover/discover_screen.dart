import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/gym.dart';
import '../../data/models/post.dart';
import '../../data/repositories/gym_repository.dart';
import '../../data/repositories/live_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../shared/navigation/main_header.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/page_loader.dart';
import '../../shared/widgets/toast.dart';
import '../feed/providers/feed_provider.dart';
import '../feed/widgets/post_card.dart';
import '../gym/widgets/gym_card.dart';

/// Web parity for `pages/app/Discover.tsx`: one search box, six tabs
/// (All / People / Gyms / Lives / Topics / Communities), actionable
/// suggestions, visible filters, and a mixed rail on the All tab.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const _tabs = <({String key, String label, IconData icon})>[
    (key: 'all', label: 'All', icon: LucideIcons.layoutGrid),
    (key: 'people', label: 'People', icon: LucideIcons.users),
    (key: 'gyms', label: 'Gyms', icon: LucideIcons.dumbbell),
    (key: 'lives', label: 'Lives', icon: LucideIcons.radio),
    (key: 'topics', label: 'Topics', icon: LucideIcons.hash),
    (key: 'communities', label: 'Communities', icon: LucideIcons.messageCircle),
  ];

  static const _fallbackGymCategories = <({String name, String label})>[
    (name: 'fitness', label: 'Fitness'),
    (name: 'strength', label: 'Strength & weights'),
    (name: 'crossfit', label: 'CrossFit'),
    (name: 'yoga', label: 'Yoga & pilates'),
    (name: 'boxing', label: 'Boxing & martial arts'),
    (name: 'running', label: 'Running'),
    (name: 'swimming', label: 'Swimming'),
    (name: 'climbing', label: 'Climbing'),
  ];

  static const _fallbackTopics = <String>[
    'fitness',
    'workout',
    'running',
    'gym',
    'yoga',
    'nutrition',
    'marathon',
    'recovery',
  ];

  final _searchController = TextEditingController();
  late final ProfileRepository _profileRepo;
  late final GymRepository _gymRepo;
  late final LiveRepository _liveRepo;

  String _activeTab = 'all';
  String _query = '';
  bool _isSearching = false;
  Timer? _debounce;

  Map<String, dynamic>? _trending;
  List<Map<String, dynamic>> _people = const [];
  List<Gym> _gyms = const [];
  List<Map<String, dynamic>> _lives = const [];
  List<Map<String, dynamic>> _gymCategories = const [];
  Set<String> _buddyRequested = <String>{};
  bool _showAllPeople = false;

  String _roleFilter = '';
  String _cityFilter = '';
  String _gymCategory = '';
  String _gymCity = '';
  String _myCity = '';
  Set<String> _interestTokens = <String>{};

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(ApiClient().dio);
    _gymRepo = GymRepository(ApiClient().dio);
    _liveRepo = LiveRepository(ApiClient().dio);
    _loadTrending();
    _loadMyCity();
    _loadGymCategories();
    _refreshTab('all');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final data = raw['data'] ?? raw['results'];
      if (data is List) return data;
    }
    return const [];
  }

  List<Map<String, dynamic>> _asMapList(dynamic raw) => _asList(raw)
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();

  Future<void> _loadTrending() async {
    try {
      final raw = await _profileRepo.getDiscoverTrending();
      final data = raw is Map ? raw['data'] : null;
      if (mounted && data is Map) {
        setState(() => _trending = Map<String, dynamic>.from(data));
      }
    } catch (_) {}
  }

  Future<void> _loadMyCity() async {
    try {
      final profile = await _profileRepo.getMyProfile();
      if (!mounted) return;
      if (profile.locationCity.isNotEmpty) {
        // Web parity: the viewer's city becomes the default people filter so
        // "near me" means a real place, and the narrowing is never silent.
        setState(() {
          _myCity = profile.locationCity;
          if (_cityFilter.isEmpty) _cityFilter = profile.locationCity;
        });
        if (_activeTab == 'people' || _activeTab == 'all') {
          _loadPeople();
        }
      }
      final prefs = profile.preferences;
      if (prefs != null) {
        final tokens = <String>{};
        void add(String s) {
          for (final w in s.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
            if (w.length > 2) tokens.add(w);
          }
        }

        for (final key in ['primary_goal', 'preferred_workouts']) {
          final value = prefs[key];
          if (value is List) {
            for (final e in value) {
              add(e.toString());
            }
          } else if (value is String) {
            add(value);
          }
        }
        final custom = prefs['custom_interests'];
        if (custom is String) add(custom);
        if (mounted) setState(() => _interestTokens = tokens);
      }
    } catch (_) {}
  }

  Future<void> _loadGymCategories() async {
    try {
      final raw = await _gymRepo.getCategories();
      final list = _asMapList(raw);
      if (mounted && list.isNotEmpty) {
        setState(() => _gymCategories = list);
      }
    } catch (_) {}
  }

  Future<void> _loadPeople() async {
    try {
      final filtering = _roleFilter.isNotEmpty || _cityFilter.isNotEmpty;
      final raw = filtering
          ? await _profileRepo.searchProfiles(
              '',
              _roleFilter.isEmpty ? null : _roleFilter,
              1,
              location: _cityFilter.isEmpty ? null : _cityFilter,
            )
          : await _profileRepo.getBuddyRecommendations();
      final list = _asMapList(raw);
      final people = filtering
          ? list
          : list
                .where((item) => item['profile'] is Map)
                .map((item) => Map<String, dynamic>.from(item['profile'] as Map))
                .toList();
      if (mounted) setState(() => _people = people);
    } catch (_) {
      if (mounted) setState(() => _people = const []);
    }
  }

  Future<void> _loadGyms() async {
    try {
      final raw = await _gymRepo.getGyms(
        category: _gymCategory.isEmpty ? null : _gymCategory,
        city: _gymCity.isEmpty ? null : _gymCity,
      );
      final gyms = _asMapList(raw).map(Gym.fromJson).toList();
      if (mounted) setState(() => _gyms = gyms);
    } catch (_) {
      if (mounted) setState(() => _gyms = const []);
    }
  }

  Future<void> _loadLives() async {
    try {
      final raw = await _liveRepo.browse(tab: 'live');
      final lives = _asMapList(raw);
      if (mounted) setState(() => _lives = lives);
    } catch (_) {
      if (mounted) setState(() => _lives = const []);
    }
  }

  Future<void> _refreshTab(String tab) async {
    final tasks = <Future<void>>[];
    if (tab == 'people' || tab == 'all') tasks.add(_loadPeople());
    if (tab == 'gyms' || tab == 'all') tasks.add(_loadGyms());
    if (tab == 'lives' || tab == 'all') tasks.add(_loadLives());
    if (tasks.isNotEmpty) await Future.wait(tasks);
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _doSearch(value.trim());
      });
    } else {
      setState(() => _isSearching = false);
      _refreshTab(_activeTab);
    }
  }

  void _setQuery(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.collapsed(
      offset: value.length,
    );
    _onQueryChanged(value);
  }

  Future<void> _doSearch(String query) async {
    setState(() => _isSearching = true);
    final tab = _activeTab;
    final tasks = <Future<void>>[];
    if (tab == 'people' || tab == 'all') {
      tasks.add(() async {
        try {
          final raw = await _profileRepo.searchProfiles(
            query,
            _roleFilter.isEmpty ? null : _roleFilter,
            1,
            location: _cityFilter.isEmpty ? null : _cityFilter,
          );
          if (mounted) {
            setState(() => _people = _asMapList(raw));
          }
        } catch (_) {
          if (mounted) setState(() => _people = const []);
        }
      }());
    }
    if (tab == 'gyms' || tab == 'all') {
      tasks.add(() async {
        try {
          final raw = await _gymRepo.getGyms(
            query: query,
            category: _gymCategory.isEmpty ? null : _gymCategory,
            city: _gymCity.isEmpty ? null : _gymCity,
          );
          if (mounted) {
            setState(() => _gyms = _asMapList(raw).map(Gym.fromJson).toList());
          }
        } catch (_) {
          if (mounted) setState(() => _gyms = const []);
        }
      }());
    }
    if (tab == 'lives' || tab == 'all') {
      tasks.add(() async {
        try {
          final raw = await _liveRepo.browse(tab: 'live');
          final lowered = query.toLowerCase();
          final lives = _asMapList(raw).where((live) {
            final title = (live['title'] as String? ?? '').toLowerCase();
            final host = (live['host'] is Map
                    ? (live['host'] as Map)['display_name'] as String? ?? ''
                    : '')
                .toLowerCase();
            return title.contains(lowered) || host.contains(lowered);
          }).toList();
          if (mounted) setState(() => _lives = lives);
        } catch (_) {}
      }());
    }
    if (tasks.isNotEmpty) await Future.wait(tasks);
    if (mounted) setState(() => _isSearching = false);
  }

  void _switchTab(String tab) {
    setState(() {
      _activeTab = tab;
      _roleFilter = '';
      _gymCategory = '';
      _gymCity = '';
      if (tab != 'people' && tab != 'all') _cityFilter = '';
    });
    _refreshTab(tab);
  }

  Future<void> _sendBuddyRequest(String username) async {
    try {
      await _profileRepo.sendBuddyRequest(username);
      if (!mounted) return;
      setState(() => _buddyRequested = {..._buddyRequested, username});
      showToast(context, 'Buddy request sent to @$username');
    } catch (_) {
      if (mounted) showToast(context, 'Could not send buddy request.');
    }
  }

  int _affinity(String text) {
    if (_interestTokens.isEmpty) return 0;
    var score = 0;
    for (final w in text.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
      if (w.length > 2 && _interestTokens.contains(w)) score++;
    }
    return score;
  }

  List<Map<String, dynamic>> _ranked(
    List<Map<String, dynamic>> items,
    String Function(Map<String, dynamic>) textOf,
  ) {
    final indexed = items.asMap().entries.toList();
    indexed.sort((a, b) {
      final cmp = _affinity(textOf(b.value)).compareTo(_affinity(textOf(a.value)));
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    });
    return indexed.map((e) => e.value).toList();
  }

  List<Map<String, dynamic>> get _trendingHashtags =>
      _ranked(_asMapList(_trending?['hashtags']), (h) => h['tag'] as String? ?? '');

  List<Map<String, dynamic>> get _trendingCommunities => _ranked(
    _asMapList(_trending?['communities']),
    (c) => c['group_name'] as String? ?? '',
  );

  List<Post> _postsFrom(dynamic raw) {
    final posts = <Post>[];
    for (final entry in _asList(raw)) {
      if (entry is Map) {
        try {
          posts.add(Post.fromJson(Map<String, dynamic>.from(entry)));
        } catch (_) {}
      }
    }
    return posts;
  }

  List<Map<String, dynamic>> get _filteredTopics {
    final tags = _trendingHashtags;
    if (_query.trim().length < 2) return tags;
    final needle = _query.trim().replaceFirst('#', '').toLowerCase();
    return tags
        .where((h) => (h['tag'] as String? ?? '').toLowerCase().contains(needle))
        .toList();
  }

  List<Map<String, dynamic>> get _filteredCommunities {
    final list = _trendingCommunities;
    if (_query.trim().length < 2) return list;
    final needle = _query.trim().toLowerCase();
    return list
        .where((c) => (c['group_name'] as String? ?? '').toLowerCase().contains(needle))
        .toList();
  }

  List<({String label, IconData icon, VoidCallback onPick})> _suggestions() {
    final out = <({String label, IconData icon, VoidCallback onPick})>[];
    final tab = _activeTab;

    if (tab == 'people' || tab == 'all') {
      out.add(
        (
          label: 'Trainers',
          icon: LucideIcons.userCheck,
          onPick: () {
            setState(() => _roleFilter = 'trainer');
            _setQuery('');
            _refreshTab(_activeTab);
          },
        ),
      );
      out.add(
        (
          label: 'Practitioners',
          icon: LucideIcons.stethoscope,
          onPick: () {
            setState(() => _roleFilter = 'practitioner');
            _setQuery('');
            _refreshTab(_activeTab);
          },
        ),
      );
      out.add(
        (
          label: 'Distributors',
          icon: LucideIcons.package,
          onPick: () {
            setState(() => _roleFilter = 'distributor');
            _setQuery('');
            _refreshTab(_activeTab);
          },
        ),
      );
      if (_cityFilter.isNotEmpty) {
        out.add((
          label: 'Near $_cityFilter',
          icon: LucideIcons.mapPin,
          onPick: () => _setQuery(''),
        ));
      }
    }

    if (tab == 'gyms' || tab == 'all') {
      final categories = _gymCategories.isNotEmpty
          ? _gymCategories
          : _fallbackGymCategories
                .map((c) => <String, dynamic>{'name': c.name, 'display_name': c.label})
                .toList();
      for (final category in categories.take(6)) {
        final name = category['name'] as String? ?? '';
        final label = category['display_name'] as String? ?? name;
        out.add((
          label: label,
          icon: LucideIcons.dumbbell,
          onPick: () {
            setState(() => _gymCategory = name);
            _setQuery('');
            _refreshTab(_activeTab);
          },
        ));
      }
      if (_gymCity.isNotEmpty || _myCity.isNotEmpty) {
        final place = _gymCity.isNotEmpty ? _gymCity : _myCity;
        out.add((
          label: 'Gyms near $place',
          icon: LucideIcons.mapPin,
          onPick: () {
            setState(() {
              _gymCity = place;
              _gymCategory = '';
            });
            _setQuery('');
            _refreshTab(_activeTab);
          },
        ));
      }
    }

    if (tab == 'lives' || tab == 'all') {
      final liveNow = _lives.where((l) => l['status'] == 'live').length;
      if (liveNow > 0) {
        out.add((
          label: 'Live now ($liveNow)',
          icon: LucideIcons.radio,
          onPick: () => _setQuery(''),
        ));
      }
      final categories = <String>{
        for (final live in _lives)
          if ((live['category'] as String? ?? '').isNotEmpty)
            live['category'] as String,
      }.take(4);
      for (final category in categories) {
        out.add((
          label: category,
          icon: LucideIcons.radio,
          onPick: () => _setQuery(category),
        ));
      }
    }

    if (tab == 'topics' || tab == 'all') {
      final hashtags = _trendingHashtags;
      if (hashtags.isNotEmpty) {
        for (final h in hashtags.take(6)) {
          final tag = h['tag'] as String? ?? '';
          out.add((
            label: '#$tag',
            icon: LucideIcons.hash,
            onPick: () => _setQuery('#$tag'),
          ));
        }
      } else {
        for (final topic in _fallbackTopics) {
          out.add((
            label: '#$topic',
            icon: LucideIcons.hash,
            onPick: () => _setQuery('#$topic'),
          ));
        }
      }
    }

    if (tab == 'communities' || tab == 'all') {
      for (final c in _trendingCommunities.take(5)) {
        out.add((
          label: c['group_name'] as String? ?? '',
          icon: LucideIcons.users,
          onPick: () => context.push('/communities/${c['id']}'),
        ));
      }
    }

    return tab == 'all' ? out.take(10).toList() : out;
  }

  String get _headerLabel => switch (_activeTab) {
    'people' => 'Recommended for you · Find nearby →',
    'gyms' => 'Browse gyms',
    'lives' => 'Trending live sessions',
    'topics' => 'Trending topics',
    'communities' => 'Active communities',
    _ => 'For you today',
  };

  @override
  Widget build(BuildContext context) {
    final isEmptySearch = _query.trim().length < 2;

    return Scaffold(
      appBar: const MainAppBar(title: 'Discover'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _padded(_buildSearch(context)),
          const SizedBox(height: 14),
          if (isEmptySearch && !_isSearching) ...[
            _padded(_buildTrendingHeader(context)),
            const SizedBox(height: 12),
          ],
          _buildTabs(context),
          const SizedBox(height: 14),
          if (isEmptySearch && !_isSearching) ...[
            ..._buildSuggestions(context),
            if (_hasFilters) ...[
              const SizedBox(height: 10),
              _padded(_buildActiveFilters(context)),
            ],
          ],
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: PageLoader()),
            )
          else ...[
            if (isEmptySearch) ..._buildEmptyQueryContent(context),
            if (!isEmptySearch) ..._buildSearchResults(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: child,
  );

  Widget _buildSearch(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onQueryChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: cs.onSurface, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search users, trainers, gyms...',
          hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          prefixIcon: Icon(
            LucideIcons.search,
            size: 19,
            color: cs.onSurfaceVariant,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => _setQuery(''),
                  tooltip: 'Clear search',
                ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: BuddyColors.green.withValues(alpha: 0.35),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTrendingHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Icon(LucideIcons.trendingUp, size: 16, color: BuddyColors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _activeTab == 'people' ? 'Recommended for you' : _headerLabel,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (_activeTab == 'people')
          GestureDetector(
            onTap: () => context.push('/buddies/find'),
            child: const Text(
              'Find nearby →',
              style: TextStyle(
                color: BuddyColors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final tab in _tabs)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => _switchTab(tab.key),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _activeTab == tab.key
                        ? BuddyColors.green
                        : cs.surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 15,
                        color: _activeTab == tab.key
                            ? BuddyColors.black
                            : cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: _activeTab == tab.key
                              ? BuddyColors.black
                              : cs.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasFilters =>
      _roleFilter.isNotEmpty ||
      _cityFilter.isNotEmpty ||
      _gymCategory.isNotEmpty ||
      _gymCity.isNotEmpty;

  Widget _buildActiveFilters(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filters = <String>[
      _roleFilter,
      _cityFilter,
      _gymCategory,
      _gymCity,
    ].where((f) => f.isNotEmpty).toList();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Filtered by',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
        ),
        for (final filter in filters)
          GestureDetector(
            onTap: () {
              setState(() {
                _roleFilter = '';
                _cityFilter = '';
                _gymCategory = '';
                _gymCity = '';
              });
              _refreshTab(_activeTab);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BuddyColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: const TextStyle(
                      color: BuddyColors.green,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.x,
                    size: 11,
                    color: BuddyColors.green,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSuggestions(BuildContext context) {
    final suggestions = _suggestions();
    if (suggestions.isEmpty) return const [];
    final cs = Theme.of(context).colorScheme;
    return [
      _padded(
        Text(
          _activeTab == 'all'
              ? 'Suggested for you'
              : 'Suggested ${_tabs.firstWhere((t) => t.key == _activeTab).label.toLowerCase()}',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final suggestion in suggestions)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: suggestion.onPick,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            suggestion.icon,
                            size: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            suggestion.label,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  // ── Empty-query content (tabs at rest) ─────────────────────────────

  List<Widget> _buildEmptyQueryContent(BuildContext context) {
    final out = <Widget>[];
    switch (_activeTab) {
      case 'all':
        out.addAll(_buildAllRails(context));
      case 'people':
        out.addAll(_buildPeopleSection(context));
      case 'gyms':
        out.addAll(_buildGymsSection(context));
      case 'lives':
        out.addAll(_buildLivesSection(context));
      case 'topics':
        out.addAll(_buildTopicsSection(context));
      case 'communities':
        out.addAll(_buildCommunitiesSection(context));
    }
    return out;
  }

  List<Widget> _buildSearchResults(BuildContext context) {
    final out = <Widget>[];
    switch (_activeTab) {
      case 'people':
        out.addAll(_buildPeopleSection(context));
      case 'gyms':
        out.addAll(_buildGymsSection(context));
      case 'lives':
        out.addAll(_buildLivesSection(context));
      case 'topics':
        out.addAll(_buildTopicsSection(context));
      case 'communities':
        out.addAll(_buildCommunitiesSection(context));
      case 'all':
        if (_people.isNotEmpty) out.addAll(_buildPeopleSection(context));
        if (_gyms.isNotEmpty) out.addAll(_buildGymsSection(context));
        if (_lives.isNotEmpty) out.addAll(_buildLivesSection(context));
        if (_filteredTopics.isNotEmpty) {
          out.addAll(_buildTopicsSection(context));
        }
        if (_filteredCommunities.isNotEmpty) {
          out.addAll(_buildCommunitiesSection(context));
        }
    }
    return out;
  }

  List<Widget> _buildAllRails(BuildContext context) {
    final out = <Widget>[];
    final cs = Theme.of(context).colorScheme;
    final trending = _trending ?? const <String, dynamic>{};
    final hashtags = _asMapList(trending['hashtags']);
    final posts = _postsFrom(trending['posts']);
    final discussions = _postsFrom(trending['discussions']);
    final communities = _asMapList(trending['communities']);
    final challenges = _asMapList(trending['challenges']);
    final lives = _asMapList(trending['lives']);
    final mealPlans = _asMapList(trending['meal_plans']);
    final offers = _asMapList(trending['offers']);

    if (hashtags.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Trending Challenges',
            LucideIcons.hash,
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        _padded(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in hashtags)
                _tagPill(
                  context,
                  '#${h['tag'] ?? ''}',
                  count: (h['count'] as num?)?.toInt(),
                  onTap: () => _setQuery('#${h['tag'] ?? ''}'),
                ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 22));
    }

    if (posts.isNotEmpty) {
      final ranked = [...posts]..sort((a, b) {
        int score(Post p) =>
            p.reactionCounts.values.fold(0, (s, v) => s + v) +
            p.commentCount +
            p.repostCount +
            p.saveCount;
        return score(b).compareTo(score(a));
      });
      out.add(
        _padded(
          _sectionTitle(context, 'Trending Posts', LucideIcons.trendingUp),
        ),
      );
      out.add(const SizedBox(height: 6));
      out.addAll(ranked.take(3).map(_postCard));
      out.add(const SizedBox(height: 22));
    }

    if (discussions.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Hot Discussions',
            LucideIcons.messageCircle,
          ),
        ),
      );
      out.add(const SizedBox(height: 6));
      out.addAll(discussions.take(3).map(_postCard));
      out.add(const SizedBox(height: 22));
    }

    if (communities.isNotEmpty) {
      out.add(
        _padded(
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  context,
                  'Active Communities',
                  LucideIcons.users,
                ),
              ),
              GestureDetector(
                onTap: () => _switchTab('communities'),
                child: const Text(
                  'See all',
                  style: TextStyle(color: BuddyColors.green, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 10));
      out.add(_padded(_communityGrid(context, communities)));
      out.add(const SizedBox(height: 22));
    }

    if (challenges.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Challenges & Competitions',
            LucideIcons.trophy,
            color: BuddyColors.gold,
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        _padded(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final event in challenges.take(4))
                _infoCard(
                  context,
                  title: event['title'] as String? ?? 'Challenge',
                  subtitle:
                      '${(event['attendee_count'] as num?)?.toInt() ?? 0} joined',
                  onTap: () =>
                      context.push('/marketplace/events/${event['id']}'),
                ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 22));
    }

    if (lives.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Lives Now & Upcoming',
            LucideIcons.radio,
            color: BuddyColors.red,
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        _padded(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final live in lives.take(5))
                _tagPill(
                  context,
                  '${live['status'] == 'live' ? '🔴 ' : ''}${live['title'] ?? ''}',
                  onTap: () => context.push('/lives/${live['id']}'),
                ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 22));
    }

    if (mealPlans.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Popular Meal Plans',
            LucideIcons.utensils,
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        _padded(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final plan in mealPlans.take(5))
                _tagPill(
                  context,
                  plan['title'] as String? ?? 'Meal plan',
                  onTap: () =>
                      context.push('/marketplace/meal-plans/${plan['id']}'),
                ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 22));
    }

    if (offers.isNotEmpty) {
      out.add(
        _padded(
          _sectionTitle(
            context,
            'Trending Giveaways & Offers',
            LucideIcons.tag,
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(_padded(Column(children: [for (final o in offers) _offerCard(context, o)])));
      out.add(const SizedBox(height: 22));
    }

    // The All tab also surfaces a short people + live rail, same as the web.
    if (_people.isNotEmpty) {
      out.add(
        _padded(
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  context,
                  'People for you',
                  LucideIcons.users,
                ),
              ),
              GestureDetector(
                onTap: () => _switchTab('people'),
                child: const Text(
                  'See all',
                  style: TextStyle(color: BuddyColors.green, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.addAll(_people.take(2).map((p) => _padded(_personRow(context, p))));
      out.add(const SizedBox(height: 22));
    }

    if (_lives.isNotEmpty) {
      out.add(
        _padded(
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  context,
                  'Live now',
                  LucideIcons.radio,
                  color: BuddyColors.red,
                ),
              ),
              GestureDetector(
                onTap: () => _switchTab('lives'),
                child: const Text(
                  'See all',
                  style: TextStyle(color: BuddyColors.green, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 8));
      out.add(
        _padded(
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final live in _lives.take(5))
                _tagPill(
                  context,
                  '${live['status'] == 'live' ? '🔴 ' : ''}${live['title'] ?? ''}',
                  onTap: () => context.push('/lives/${live['id']}'),
                ),
            ],
          ),
        ),
      );
      out.add(const SizedBox(height: 22));
    }

    if (out.isEmpty) {
      out.add(
        _padded(
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Nothing trending right now. Try searching.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  // ── Tab sections ───────────────────────────────────────────────────

  List<Widget> _buildPeopleSection(BuildContext context) {
    if (_people.isEmpty) {
      return [
        _emptyCard(
          context,
          icon: LucideIcons.trendingUp,
          message: _query.trim().length >= 2
              ? 'No users found for "${_query.trim()}".'
              : 'No recommended users right now. Try searching instead.',
        ),
      ];
    }
    final visible = _showAllPeople ? _people : _people.take(4).toList();
    return [
      for (final person in visible) _padded(_personCard(context, person)),
      if (_people.length > 4)
        _padded(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _showAllPeople = !_showAllPeople),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _showAllPeople
                      ? 'Show less'
                      : 'See more (${_people.length - 4} more)',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
        ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildGymsSection(BuildContext context) {
    if (_gyms.isEmpty) {
      return [
        _emptyCard(
          context,
          icon: LucideIcons.dumbbell,
          message: _query.trim().length >= 2
              ? 'No gyms found for "${_query.trim()}".'
              : 'No gyms to browse right now. Try searching instead.',
        ),
      ];
    }
    return [
      for (final gym in _gyms)
        GymCard(gym: gym, onTap: () => context.push('/gyms/${gym.handle}')),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildLivesSection(BuildContext context) {
    if (_lives.isEmpty) {
      return [
        _emptyCard(
          context,
          icon: LucideIcons.radio,
          message: _query.trim().length >= 2
              ? 'No matching live sessions found.'
              : 'No live sessions right now.',
        ),
      ];
    }
    return [
      for (final live in _ranked(
        _lives,
        (l) =>
            '${l['title'] ?? ''} ${l['category'] ?? ''} '
            '${l['host'] is Map ? (l['host'] as Map)['display_name'] ?? '' : ''}',
      ))
        _padded(_liveCard(context, live)),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildTopicsSection(BuildContext context) {
    final topics = _filteredTopics;
    if (topics.isEmpty) {
      return [
        _emptyCard(
          context,
          icon: LucideIcons.hash,
          message: _query.trim().length >= 2
              ? 'No topics found for "${_query.trim()}".'
              : 'No trending topics right now.',
        ),
      ];
    }
    return [
      _padded(_sectionTitle(context, 'Trending Topics', LucideIcons.hash)),
      const SizedBox(height: 8),
      _padded(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final h in topics)
              _tagPill(
                context,
                '#${h['tag'] ?? ''}',
                count: (h['count'] as num?)?.toInt(),
                onTap: () => _setQuery('#${h['tag'] ?? ''}'),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildCommunitiesSection(BuildContext context) {
    final communities = _filteredCommunities;
    if (communities.isEmpty) {
      return [
        _emptyCard(
          context,
          icon: LucideIcons.users,
          message: _query.trim().length >= 2
              ? 'No communities found for "${_query.trim()}".'
              : 'No active communities right now.',
        ),
      ];
    }
    return [
      _padded(
        _sectionTitle(context, 'Active Communities', LucideIcons.users),
      ),
      const SizedBox(height: 10),
      _padded(_communityGrid(context, communities)),
      const SizedBox(height: 16),
    ];
  }

  // ── Small building blocks ──────────────────────────────────────────

  Widget _sectionTitle(
    BuildContext context,
    String title,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? BuddyColors.green),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _tagPill(
    BuildContext context,
    String label, {
    int? count,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: BuddyColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCard(BuildContext context, Map<String, dynamic> offer) {
    final cs = Theme.of(context).colorScheme;
    final type = offer['type'] as String? ?? '';
    final data = offer['data'] is Map
        ? Map<String, dynamic>.from(offer['data'] as Map)
        : const <String, dynamic>{};
    final isDiscount = type == 'discount_code';
    final discount = data['discount_type'] == 'percentage'
        ? '${data['discount_pct']}% off'
        : 'Discount';
    final title = isDiscount
        ? '$discount  "${data['code'] ?? ''}"'
        : data['title'] as String? ?? 'Event';
    final subtitle = isDiscount
        ? data['description'] as String? ?? ''
        : 'Free event';
    final accent = isDiscount ? BuddyColors.gold : BuddyColors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.ticket, size: 17, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (isDiscount) {
                context.push('/marketplace');
              } else {
                context.push('/marketplace/events/${data['id']}');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                isDiscount ? 'Use offer' : 'View',
                style: TextStyle(color: cs.onSurface, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _communityGrid(
    BuildContext context,
    List<Map<String, dynamic>> communities,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final community in communities)
              SizedBox(
                width: width,
                child: _communityCard(context, community),
              ),
          ],
        );
      },
    );
  }

  Widget _communityCard(
    BuildContext context,
    Map<String, dynamic> community,
  ) {
    final cs = Theme.of(context).colorScheme;
    final name = community['group_name'] as String? ?? '';
    final cover = community['cover_url'] as String? ?? '';
    final members = (community['member_count'] as num?)?.toInt() ?? 0;
    final posts = (community['post_count'] as num?)?.toInt() ?? 0;
    final role =
        (community['role'] ?? community['my_role']) as String? ?? 'member';
    final description = community['description'] as String? ?? '';

    return GestureDetector(
      onTap: () => context.push('/communities/${community['id']}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: cover,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) =>
                            ColoredBox(color: cs.surfaceContainerHighest),
                      )
                    else
                      ColoredBox(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: Text(
                            name.isEmpty ? '?' : name[0].toUpperCase(),
                            style: const TextStyle(
                              color: BuddyColors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$members members',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
                const Spacer(),
                Text(
                  '$posts posts',
                  style: TextStyle(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _personRow(BuildContext context, Map<String, dynamic> person) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/${person['username']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Avatar(
              src: person['avatar_url'] as String?,
              alt: person['display_name'] as String? ?? '',
              size: AvatarSize.lg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['display_name'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${person['username'] ?? ''} · '
                    '${(person['buddy_count'] as num?)?.toInt() ?? 0} buddies',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/${person['username']}'),
              child: const Text(
                'View',
                style: TextStyle(color: BuddyColors.green, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personCard(BuildContext context, Map<String, dynamic> person) {
    final cs = Theme.of(context).colorScheme;
    final username = person['username'] as String? ?? '';
    final name = person['display_name'] as String? ?? username;
    final bio = person['bio'] as String? ?? '';
    final city = person['location_city'] as String? ?? '';
    final verification = person['verification_status'] as String? ?? '';
    final buddies = (person['buddy_count'] as num?)?.toInt() ?? 0;
    final followers = (person['follower_count'] as num?)?.toInt() ?? 0;
    final requested = _buddyRequested.contains(username);
    final isBuddy =
        person['is_buddy'] == true || person['buddy_status'] == 'accepted';
    final badge = switch (verification) {
      'trainer' => (label: 'Trainer', color: BuddyColors.green),
      'practitioner' => (label: 'Practitioner', color: BuddyColors.gold),
      'id' => (label: 'Verified', color: const Color(0xFFCBD5E1)),
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/$username'),
            child: Avatar(
              src: person['avatar_url'] as String?,
              alt: name,
              size: AvatarSize.lg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/$username'),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badge.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge.label,
                            style: TextStyle(
                              color: badge.color,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@$username',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
                if (city.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '$buddies buddies · $followers followers',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              if (isBuddy)
                _smallBadgeButton(
                  context,
                  icon: LucideIcons.userCheck,
                  label: 'Buddies',
                )
              else
                _smallOutlinedButton(
                  context,
                  icon: LucideIcons.handshake,
                  label: requested ? 'Requested' : 'Buddy Up',
                  onPressed: requested ? null : () => _sendBuddyRequest(username),
                ),
              const SizedBox(height: 6),
              _smallGhostButton(
                context,
                'View',
                onPressed: () => context.push('/$username'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallOutlinedButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: onPressed == null
                ? cs.outlineVariant
                : BuddyColors.green.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: onPressed == null ? cs.onSurfaceVariant : BuddyColors.green,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: onPressed == null ? cs.onSurfaceVariant : BuddyColors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallBadgeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _smallGhostButton(
    BuildContext context,
    String label, {
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(color: BuddyColors.green, fontSize: 11),
        ),
      ),
    );
  }

  Widget _liveCard(BuildContext context, Map<String, dynamic> live) {
    final cs = Theme.of(context).colorScheme;
    final host = live['host'] is Map
        ? Map<String, dynamic>.from(live['host'] as Map)
        : const <String, dynamic>{};
    final isLive = live['status'] == 'live';
    final type = (live['liveType'] ?? live['live_type'] ?? '')
        .toString()
        .replaceAll('_', ' ');
    final category = live['category'] as String? ?? '';
    final viewers =
        (live['viewerPeak'] ?? live['viewer_peak'] ?? live['viewer_count'] ?? 0)
            as num?;

    return GestureDetector(
      onTap: () => context.push('/lives/${live['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Avatar(
              src: host['avatar_url'] as String?,
              alt: host['display_name'] as String? ?? '',
              size: AvatarSize.lg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          live['title'] as String? ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: BuddyColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: BuddyColors.red,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    host['display_name'] as String? ?? '',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      '${viewers?.toInt() ?? 0} viewers',
                      if (type.isNotEmpty) type,
                      if (category.isNotEmpty) category,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/lives/${live['id']}'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: BuddyColors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: BuddyColors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postCard(Post post) {
    return PostCard(
      post: post,
      onComment: (id) => context.push('/feed/$id'),
      onReact: (id, reaction) {
        if (reaction.isEmpty) {
          final current = ref.read(feedProvider).posts.firstWhere(
            (p) => p.id == id,
            orElse: () => post,
          );
          final emoji = current.userReaction;
          if (emoji != null) {
            ref.read(feedProvider.notifier).reactTo(id, emoji);
          }
        } else {
          ref.read(feedProvider.notifier).reactTo(id, reaction);
        }
      },
    );
  }

  Widget _emptyCard(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final cs = Theme.of(context).colorScheme;
    return _padded(
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
