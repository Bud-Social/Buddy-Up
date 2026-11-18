import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/post.dart';
import '../../messaging/providers/messaging_provider.dart';

/// Posts surfaces for the gym console's Posts tab.
///
/// Three feeds, same serializer shape: the gym's own feed
/// (`/gyms/<slug>/feed/`), the public home feed (`/feed/`), and the merged
/// saved list (already in `gym_insights_provider.dart`). Decoding is
/// defensive — a mismatched payload degrades to an empty list.

List<Post> _rows(dynamic payload) {
  final data = payload is Map<String, dynamic> ? (payload['data'] ?? payload['items']) : payload;
  final list = data is List ? data : (data is Map ? data['items'] : null);
  if (list is! List) return const [];
  return list
      .whereType<Map>()
      .map((row) => Post.fromJson(Map<String, dynamic>.from(row)))
      .toList();
}

/// The gym's own feed — posts authored by the gym, newest first.
final gymOwnFeedProvider = FutureProvider.family.autoDispose<List<Post>, String>((ref, slug) async {
  final dio = ref.read(apiClientProvider4).dio;
  final res = await dio.get('/gyms/$slug/feed/');
  return _rows(res.data);
});

/// The public home feed as it lands for this member — used by the gym console
/// so staff can engage with it *as the gym*. Gym-authored posts are included
/// (visible in the gym console's own Home feed tab, as intended).
final gymHomeFeedProvider = FutureProvider.autoDispose<List<Post>>((ref) async {
  final dio = ref.read(apiClientProvider4).dio;
  final res = await dio.get('/feed/', queryParameters: {'tab': 'for_you', 'include_gym': '1'});
  return _rows(res.data);
});
