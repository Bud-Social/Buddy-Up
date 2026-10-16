/// Client-side mirror of the backend's publishing gates.
///
/// Mirrors `_can_create_meal_plan` and `_resolve_commerce_publisher` in
/// `backend/apps/marketplace/views.py`, and exists for one reason only: **do not
/// offer an action the server will refuse.** It is convenience, not security —
/// every one of these endpoints re-checks server-side, and a caller who forges
/// their way past this file gets a 403 and nothing else.
///
/// Three deliberate rules:
///
///  1. **Role alone proves nothing.** `Profile.role` was client-declared at
///     registration, so an elevated role only counts alongside the
///     `verification_status` that certifies it — the same conjunction
///     `Profile.is_verified_role()` enforces on the server.
///  2. **Unknown means no.** Every signal defaults to the narrower answer, so a
///     field this build has never heard of, or a probe that failed, can only hide
///     an entry. A half-rolled-out backend cannot widen anybody's access.
///  3. **Kept free of Flutter and Riverpod imports**, so the matrix is testable
///     on its own and the widget layer stays presentational.
library;

/// Verification status that certifies each elevated role.
///
/// Mirrors `Profile.ROLE_VERIFICATION_STATUSES`. A role missing from this map
/// has no verification vocabulary at all and therefore can never be "verified".
const Map<String, String> kRoleVerificationStatuses = {
  'trainer': 'trainer',
  'practitioner': 'practitioner',
  'distributor': 'distributor',
};

/// The roles whose verification certifies meal-plan authority.
const Set<String> kMealPlanRoles = {'trainer', 'practitioner'};

/// Gym memberships that count as running the gym.
const Set<String> kGymOwnerMembershipRoles = {'owner', 'co_owner'};

/// Shop memberships that count as publishing under the shop.
///
/// Deliberately excludes `staff`: the backend's `_resolve_creator_shop` filters
/// on the same pair, so a staff member who sees a "create product" button would
/// get a 403 the moment they pressed it.
const Set<String> kPublishingShopRoles = {'owner', 'manager'};

/// True when [role] is an elevated role that [verificationStatus] actually
/// certifies.
///
/// The conjunction is the point: `role='trainer'` with `verification_status='none'`
/// is an unverified claim, and the server's `is_verified_role()` returns False
/// for it.
bool isVerifiedRole(String? role, String? verificationStatus) {
  final expected = kRoleVerificationStatuses[role?.trim() ?? ''];
  if (expected == null) return false;
  return verificationStatus?.trim() == expected;
}

/// Everything the gates below need to know about the caller.
///
/// Assembled once by the provider layer from the profile and the two ownership
/// probes, then passed to [canCreateMealPlan] / [canPublishCommerce].
class CommercePermissions {
  /// The caller's `Profile.role`.
  final String role;

  /// The caller's `Profile.verification_status`.
  final String verificationStatus;

  /// Gym handles where the caller is owner or co-owner, from `ownedGymsProvider`.
  final Set<String> ownedGymHandles;

  /// The caller's own shops, carrying `my_role` from `GET /shops/my/`.
  final List<MyShopRole> myShops;

  const CommercePermissions({
    this.role = 'user',
    this.verificationStatus = 'none',
    this.ownedGymHandles = const {},
    this.myShops = const [],
  });

  /// Nobody holds anything. Every gate below is closed.
  static const CommercePermissions none = CommercePermissions();

  /// True when the caller owns or co-owns at least one gym.
  ///
  /// Handles are trimmed before the emptiness test, because a row that parses to
  /// whitespace is as good as no gym at all and must not open the gate.
  bool get runsAGym => ownedGymHandles.any((handle) => handle.trim().isNotEmpty);

  /// True when the caller holds an owner or manager membership somewhere.
  ///
  /// True is only necessary, never sufficient: the server additionally demands a
  /// verified shop and a ready payout setup, neither of which this file can see.
  bool get publishesUnderAShop =>
      myShops.any((shop) => kPublishingShopRoles.contains(shop.role));

  /// True when the caller may press "create meal plan".
  ///
  /// A verified trainer or practitioner, or anyone who runs a gym. Note what is
  /// *not* required: a shop. `_can_create_meal_plan` deliberately dropped the shop
  /// requirement, so a gym owner with no storefront can still publish nutrition.
  bool get canCreateMealPlan =>
      (isVerifiedRole(role, verificationStatus) && kMealPlanRoles.contains(role)) ||
      runsAGym;

  /// True when the caller may press "create product" or "create event".
  ///
  /// Products and events are commerce: a verified distributor with no shop, or
  /// an owner/manager of a shop. Programmes are *not* gated here — the backend
  /// does not gate them either, and inventing a rule would hide a button the
  /// server happily accepts.
  bool get canPublishCommerce =>
      (isVerifiedRole(role, verificationStatus) && role == 'distributor') ||
      publishesUnderAShop;
}

/// A shop from `GET /marketplace/shops/my/`, reduced to the one field that
/// decides publishing rights.
class MyShopRole {
  final String handle;

  /// The caller's membership role in this shop: owner, manager, staff, …
  final String role;

  const MyShopRole({required this.handle, required this.role});

  factory MyShopRole.fromJson(Map<String, dynamic> json) => MyShopRole(
        handle: '${json['handle'] ?? ''}'.trim(),
        role: '${json['my_role'] ?? ''}'.trim(),
      );
}

/// Turn the raw `shops/my/` payload into [MyShopRole]s.
///
/// Every membership the caller holds is returned, including `staff` — deciding
/// what a membership *entitles* them to is [CommercePermissions.publishesUnderAShop]'s
/// job, and keeping that rule in one place is what stops it drifting. Rows with
/// no usable `my_role` are dropped rather than defaulted: an unrecognised
/// membership must never read as owner.
List<MyShopRole> parseMyShopRoles(dynamic body) {
  final data = body is Map ? body['data'] : body;
  if (data is! List) return const [];
  final roles = <MyShopRole>[];
  for (final row in data.whereType<Map<String, dynamic>>()) {
    final role = '${row['my_role'] ?? ''}'.trim();
    if (role.isEmpty) continue;
    roles.add(MyShopRole(handle: '${row['handle'] ?? ''}'.trim(), role: role));
  }
  return roles;
}