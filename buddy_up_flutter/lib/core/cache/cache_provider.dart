import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_service.dart';

final cacheServiceProvider = FutureProvider<CacheService>((_) async {
  return CacheService.create();
});
