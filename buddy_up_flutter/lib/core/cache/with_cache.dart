import 'dart:async';
import 'cache_provider.dart';

Future<T> withCache<T>(dynamic ref, String key, Future<T> Function() fetch,
    {Duration ttl = const Duration(minutes: 5)}) async {
  final cache = await ref.read(cacheServiceProvider.future);
  final cached = await cache.get<Map<String, dynamic>>(key);
  if (cached != null && !cache.isExpired(key, ttl: ttl)) {
    return cached as T;
  }
  try {
    final result = await fetch();
    unawaited(cache.set(key, result));
    return result;
  } catch (e) {
    if (cached != null) return cached as T;
    rethrow;
  }
}

Future<void> invalidateCache(dynamic ref, String key) async {
  final cache = await ref.read(cacheServiceProvider.future);
  await cache.invalidate(key);
}
