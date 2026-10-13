import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/marketplace.dart';
import '../providers/marketplace_provider.dart';

/// The caller's most recent station application.
///
/// `POST /marketplace/station-applications/` is the only way to learn an
/// application's status: there is no "my applications" read endpoint, so the
/// response body is the single place the caller can read it back from. This
/// holder is how the wizard hands that body to the management screen instead of
/// stranding it in a `State` field.
///
/// The consequence is that the status is session-scoped: after a cold start the
/// card returns to offering the application button rather than inventing a
/// status it never saw.
class StationApplicationNotifier extends Notifier<StationApplication?> {
  @override
  StationApplication? build() => null;

  void record(StationApplication? application) => state = application;
}

final stationApplicationProvider =
    NotifierProvider<StationApplicationNotifier, StationApplication?>(
        StationApplicationNotifier.new);

/// Submit an application and remember the result.
///
/// Returns the created application so the wizard can render it immediately. The
/// caller supplies the whole body — the owner pair plus the site details the
/// wizard collected — because the serializer decides what is required and this
/// layer should not second-guess it.
Future<StationApplication> submitStationApplication(
  WidgetRef ref,
  Map<String, dynamic> payload,
) async {
  final raw = await ref.read(marketplaceRepositoryProvider).applyForStation(payload);
  final application = StationApplication.fromJson(
      raw['data'] as Map<String, dynamic>? ?? <String, dynamic>{});
  ref.read(stationApplicationProvider.notifier).record(application);
  return application;
}