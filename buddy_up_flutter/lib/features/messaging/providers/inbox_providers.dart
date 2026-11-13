import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/messaging.dart';
import '../../../data/repositories/messaging_repository.dart';
import '../providers/messaging_provider.dart';

/// ── Stories ───────────────────────────────────────────────────────────────
/// Last 24h of `moment` posts from buddies + followed users, grouped by
/// author. One round trip for the strip and the Stories tab.

class StoriesState {
  final List<StoryReel> reels;
  final bool isLoading;
  final String? error;

  const StoriesState({this.reels = const [], this.isLoading = false, this.error});

  StoriesState copyWith({List<StoryReel>? reels, bool? isLoading, String? error}) {
    return StoriesState(
      reels: reels ?? this.reels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StoriesNotifier extends Notifier<StoriesState> {
  @override
  StoriesState build() => const StoriesState(isLoading: true);

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await _repository.getStories();
      final data = raw['data'] as List? ?? const [];
      final reels = data
          .map((e) => StoryReel.fromJson(e as Map<String, dynamic>))
          .where((r) => r.stories.isNotEmpty)
          .toList();
      state = state.copyWith(reels: reels, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final storiesProvider = NotifierProvider<StoriesNotifier, StoriesState>(StoriesNotifier.new);

/// ── Calls ─────────────────────────────────────────────────────────────────
/// Every call touching the viewer, newest first, with the live session folded
/// in so the tab can render a Rejoin pill.

class CallHistoryState {
  final List<CallHistoryEntry> entries;
  final bool isLoading;
  final String? error;

  const CallHistoryState({this.entries = const [], this.isLoading = false, this.error});

  CallHistoryState copyWith({List<CallHistoryEntry>? entries, bool? isLoading, String? error}) {
    return CallHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CallHistoryNotifier extends Notifier<CallHistoryState> {
  @override
  CallHistoryState build() => const CallHistoryState(isLoading: true);

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await _repository.getCallHistory();
      final data = raw['data'] as List? ?? const [];
      final entries = data
          .map((e) => CallHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final callHistoryProvider =
    NotifierProvider<CallHistoryNotifier, CallHistoryState>(CallHistoryNotifier.new);

/// ── Communities (inbox) ───────────────────────────────────────────────────
/// The community conversation rows for the Community tab. Separate from the
/// main inbox so the two screens can never disagree.

class CommunityConversationsState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  const CommunityConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityConversationsState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return CommunityConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunityConversationsNotifier extends Notifier<CommunityConversationsState> {
  @override
  CommunityConversationsState build() => const CommunityConversationsState(isLoading: true);

  MessagingRepository get _repository => ref.read(messagingRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final raw = await _repository.getConversations(kind: 'communities');
      final data = raw['data'] as List? ?? const [];
      final conversations = data
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final communityConversationsProvider =
    NotifierProvider<CommunityConversationsNotifier, CommunityConversationsState>(
  CommunityConversationsNotifier.new,
);


