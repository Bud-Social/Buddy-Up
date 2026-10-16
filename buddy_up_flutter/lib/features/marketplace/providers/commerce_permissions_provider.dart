import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_provider.dart';
import '../../gym/providers/gym_provider.dart';
import '../utils/commerce_permissions.dart';
import 'marketplace_provider.dart';

/// The caller's publishing rights, assembled from the same signals the backend
/// reads.
///
/// Deliberately an `AsyncProvider` over live data rather than a value computed
/// once at sign-in: gym and shop ownership change *after* sign-in — somebody
/// approves them through verification — and a cached answer would keep hiding a
/// button the server now accepts.
///
/// The error branch is `CommercePermissions.none`, not a throw. Every source is
/// already an IO probe that can fail independently, and a failed probe must be
/// able to close a gate but never crash the Shop dashboard. The server is the
/// authority either way: a wrong "yes" here costs the user a 403, and a
/// conservative "no" only costs them a button they can still reach by URL.
final commercePermissionsProvider = FutureProvider<CommercePermissions>((ref) async {
  final auth = ref.watch(authProvider);
  final profile = auth.profile;
  if (!auth.isAuthenticated || profile == null) return CommercePermissions.none;

  // `ownedGymsProvider` already swallows its own failures; an empty list is the
  // safe reading either way, because a gym owner who is not detected simply
  // does not see the meal-plan button.
  final ownedGyms = await ref.watch(ownedGymsProvider.future);

  final shops = await ref
      .watch(myShopsProvider.future)
      .then(parseMyShopRoles)
      .onError((_, _) => const <MyShopRole>[]);

  return CommercePermissions(
    role: profile.role,
    verificationStatus: profile.verificationStatus,
    ownedGymHandles: ownedGyms.map((gym) => gym.handle).toSet(),
    myShops: shops,
  );
});

/// The one boolean the Shop's "create" affordances actually branch on.
///
/// A `FutureProvider` while loading means *no*, so a create button never flashes
/// into view for someone who will be refused.
final canCreateMealPlanProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(commercePermissionsProvider).whenData((p) => p.canCreateMealPlan));

/// Whether the caller may create a product or an event.
final canPublishCommerceProvider = Provider<AsyncValue<bool>>((ref) =>
    ref.watch(commercePermissionsProvider).whenData((p) => p.canPublishCommerce));