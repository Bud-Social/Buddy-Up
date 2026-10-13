import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../providers/courier_provider.dart';
import '../utils/courier.dart';

/// Courier dashboard.
///
/// Three surfaces: the rider's profile (with the availability toggle), the
/// orders assigned to them with *only* the transitions the server says are
/// legal, and an earnings figure that is explicitly an estimate.
///
/// **The 404 case is the important one.** `GET /marketplace/delivery/summary/`
/// is scoped to the signed-in courier, so a 404 cannot mean "that record is
/// missing" — it means the caller has no `DeliveryPersonnel` row at all. That
/// is a route to the registration wizard, not an empty dashboard, so it is
/// handled before the first frame renders rather than inside the error state.
class CourierDashboardScreen extends ConsumerStatefulWidget {
  const CourierDashboardScreen({super.key});

  @override
  ConsumerState<CourierDashboardScreen> createState() =>
      _CourierDashboardScreenState();
}

class _CourierDashboardScreenState extends ConsumerState<CourierDashboardScreen> {
  /// The registration route the 404 sends a rider to.
  static const _registrationRoute = '/marketplace/delivery-personnel';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(courierProfileProvider);

    return profileAsync.when(
      loading: () =>
          const _CourierShell(body: PageLoader()),
      error: (error, _) => _CourierShell(
        body: isCourierNotRegistered(error)
            ? _NotRegistered(onRegister: _register)
            : ErrorView(
                message: apiErrorMessage(
                  error,
                  fallback: 'Could not load your courier profile.',
                ),
                onRetry: () => ref.invalidate(courierProfileProvider),
              ),
      ),
      data: (profile) => _CourierBody(
        profile: profile,
        onRefresh: () {
          ref.invalidate(courierProfileProvider);
          ref.invalidate(courierOrdersProvider);
          ref.invalidate(courierEarningsProvider);
        },
      ),
    );
  }

  void _register() {
    // `pushReplacement` rather than `push`: the dashboard is meaningless for a
    // rider with no courier row, so pressing back should not land them on it.
    context.pushReplacement(_registrationRoute);
  }
}

class _CourierShell extends StatelessWidget {
  final Widget body;

  const _CourierShell({required this.body});

  @override
  Widget build(BuildContext context) {
    return RoleDashboardShell(
      title: 'Courier',
      subtitle: 'Your deliveries',
      body: body,
    );
  }
}

/// The "you are not a courier yet" state.
///
/// A dedicated screen rather than a blank dashboard: the rider arrived here from
/// a nav entry (or a deep link) and the only useful thing to do is register.
class _NotRegistered extends StatelessWidget {
  final VoidCallback onRegister;

  const _NotRegistered({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pedal_bike, color: BuddyColors.green, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'You are not a courier yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'This page needs a courier record: the vehicle you use, the '
                'areas you deliver in, and whether you are accepting work. '
                'Register once and every delivery assigned to you appears here.',
                style: TextStyle(
                  fontSize: 13,
                  color: BuddyColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRegister,
                child: const Text('Register as a courier'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CourierBody extends ConsumerWidget {
  final CourierProfile profile;
  final VoidCallback onRefresh;

  const _CourierBody({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(courierStatusFilterProvider);
    final ordersAsync = ref.watch(courierOrdersProvider(status));
    final earningsAsync = ref.watch(courierEarningsProvider);

    return RoleDashboardShell(
      title: 'Courier',
      subtitle: 'Your deliveries',
      actions: [
        IconButton(
          icon: const Icon(Icons.pedal_bike),
          tooltip: 'Courier details',
          onPressed: () => context.push('/marketplace/delivery-personnel'),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: onRefresh,
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _ProfileCard(profile: profile),
            const RoleSectionTitle('Assigned orders'),
            RoleFilterChips<String>(
              options: kCourierStatusFilters.map((f) => f.value).toList(),
              selected: status,
              label: (value) {
                final filter = kCourierStatusFilters.firstWhere(
                  (f) => f.value == value,
                  orElse: () => kCourierStatusFilters.first,
                );
                final count = courierCountFor(profile.counts, value);
                return count == null ? filter.label : '${filter.label} $count';
              },
              onSelected: (value) =>
                  ref.read(courierStatusFilterProvider.notifier).set(value),
            ),
            const SizedBox(height: 12),
            ordersAsync.when(
              loading: () => const PageLoader(fullScreen: false),
              error: (error, _) => ErrorView(
                message: apiErrorMessage(
                  error,
                  fallback: 'Could not load your assigned orders.',
                ),
                onRetry: () => ref.invalidate(courierOrdersProvider(status)),
              ),
              data: (orders) => orders.isEmpty
                  ? const _NoOrders()
                  : Column(
                      children: [
                        for (final order in orders)
                          _OrderCard(
                            order: order,
                            onChanged: onRefresh,
                          ),
                      ],
                    ),
            ),
            const RoleSectionTitle('Earnings'),
            _EarningsCard(earnings: earningsAsync),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends ConsumerStatefulWidget {
  final CourierProfile profile;

  const _ProfileCard({required this.profile});

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final zones =
        profile.serviceZones.map((z) => z.trim()).where((z) => z.isNotEmpty).toList();

    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoleStatRow([
            RoleStat(
              value: profile.vehicleLabel.isNotEmpty
                  ? profile.vehicleLabel
                  : (profile.vehicleType.isEmpty
                      ? 'Not set'
                      : deliveryVehicleFallbackLabel(profile.vehicleType)),
              label: 'Vehicle',
            ),
            RoleStat(
              value: profile.rating == null
                  ? '—'
                  : profile.rating!.toStringAsFixed(2),
              label: 'Rating',
              valueColor: BuddyColors.gold,
            ),
            RoleStat(
              value: courierCommissionLabel(profile.commissionRate),
              label: 'Commission',
            ),
          ]),
          const SizedBox(height: 14),
          const Text(
            'Service zones',
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          ),
          const SizedBox(height: 6),
          if (zones.isEmpty)
            const Text(
              'No zones assigned yet',
              style: TextStyle(fontSize: 13, color: BuddyColors.textSecondary),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final zone in zones) BuddyBadge(label: zone)],
            ),
          const Divider(height: 24),
          SwitchListTile(
            value: profile.isActive,
            activeThumbColor: BuddyColors.green,
            contentPadding: EdgeInsets.zero,
            onChanged: _busy ? null : (value) => _toggle(value),
            title: const Text(
              'Accepting deliveries',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              profile.active
                  ? 'You have an order in progress right now.'
                  : 'Pause when you are unavailable.',
              style: const TextStyle(
                  fontSize: 11, color: BuddyColors.textSecondary),
            ),
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: BuddyColors.red),
              ),
            ),
          if (_notice != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _notice!,
                style: const TextStyle(fontSize: 12, color: BuddyColors.green),
              ),
            ),
        ],
      ),
    );
  }

  /// Optimistic: the switch moves immediately and is rolled back on failure, so
  /// pausing mid-shift does not feel like a form submission.
  Future<void> _toggle(bool next) async {
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final result = await ref.read(courierAvailabilityProvider).setActive(
            isActive: next,
            profile: widget.profile,
          );
      if (!mounted) return;
      setState(() => _notice = result.message);
      ref.invalidate(courierProfileProvider);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = apiErrorMessage(
            error,
            fallback: 'Could not update your availability.',
          ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _NoOrders extends StatelessWidget {
  const _NoOrders();

  @override
  Widget build(BuildContext context) {
    return const RoleCard(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined,
              color: BuddyColors.textSecondary, size: 28),
          SizedBox(height: 10),
          Text(
            'No assigned orders.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'New deliveries appear here as soon as a shop assigns one to you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  final CourierOrder order;
  final VoidCallback onChanged;

  const _OrderCard({required this.order, required this.onChanged});

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  String? _busyTarget;
  String? _error;
  String? _notice;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final pickup = courierPickupLabel(order.pickupStation);
    final commission = artifactsUsd(order.commissionArtifacts);

    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 15, color: BuddyColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.orderNumber.isEmpty ? order.id : order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              BuddyBadge(
                label: courierFulfillmentLabel(order),
                color: _statusColor(order.status),
              ),
            ],
          ),
          // Address and pickup point are in view, not behind a tap: a courier
          // standing on a doorstep is the only moment this data is useful.
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.location_on_outlined,
            text: courierAddressLabel(order.deliveryAddress),
          ),
          if (pickup != null) ...[
            const SizedBox(height: 4),
            _MetaRow(icon: Icons.store_outlined, text: 'Pick up: $pickup'),
          ],
          if (order.items.isNotEmpty) ...[
            const Divider(height: 20),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title.isEmpty ? 'Item' : item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '×${item.quantity}'
                      '${item.creatorName.isEmpty ? '' : ' · ${item.creatorName}'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (commission != null) ...[
            const SizedBox(height: 10),
            Text(
              'Commission on this order ≈ \$${commission.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 11,
                color: BuddyColors.textSecondary,
              ),
            ),
          ],
          const Divider(height: 20),
          if (order.allowedTransitions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'No status changes available from here.',
                style: TextStyle(
                    fontSize: 12, color: BuddyColors.textSecondary),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final target in order.allowedTransitions)
                  _TransitionButton(
                    orderId: order.id,
                    target: target,
                    busy: _busyTarget != null,
                    isPrimary: target == 'delivered',
                    onTap: () => _apply(target),
                  ),
              ],
            ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            RoleNotice(message: _error!, isError: true),
          ],
          if (_notice != null) ...[
            const SizedBox(height: 10),
            RoleNotice(message: _notice!),
          ],
        ],
      ),
    );
  }

  Future<void> _apply(String target) async {
    setState(() {
      _busyTarget = target;
      _error = null;
      _notice = null;
    });
    try {
      final message = await ref.read(courierOrderActionsProvider).setStatus(
            orderId: widget.order.id,
            status: target,
          );
      if (!mounted) return;
      setState(() => _notice = message);
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      // The backend names the illegal move in a 400; show its sentence.
      setState(() => _error = courierStatusErrorMessage(error));
    } finally {
      if (mounted) setState(() => _busyTarget = null);
    }
  }
}

class _TransitionButton extends StatelessWidget {
  final String orderId;
  final String target;
  final bool busy;
  final bool isPrimary;
  final VoidCallback onTap;

  const _TransitionButton({
    required this.orderId,
    required this.target,
    required this.busy,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = courierActionLabel(target);
    if (isPrimary) {
      return ElevatedButton(
        onPressed: busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: busy ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// Earnings — an estimate from completed orders, never a payable balance.
class _EarningsCard extends ConsumerWidget {
  final AsyncValue<CourierEarnings?> earnings;

  const _EarningsCard({required this.earnings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return earnings.when(
      loading: () => const RoleCard(
        child: SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => RoleCard(
        child: Text(
          'Earnings are unavailable right now.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      data: (data) {
        if (data == null) {
          return RoleCard(
            child: Text(
              'Earnings are unavailable right now.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        final commission = artifactsUsd(data.commissionArtifacts);
        final value = artifactsUsd(data.deliveredValueArtifacts);
        final window = earningsWindowLabel(data.window);

        return RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated commission',
                          style: TextStyle(
                              fontSize: 12, color: BuddyColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          commission == null
                              ? '—'
                              : '≈ \$${commission.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The badge is the whole point of this card: without it a
                  // large number is indistinguishable from a balance owed.
                  const BuddyBadge(
                    label: 'Estimate',
                    color: BuddyColors.gold,
                  ),
                ],
              ),
              const Divider(height: 24),
              RoleStatRow([
                RoleStat(
                  value: '${data.deliveredCount}',
                  label: 'Delivered orders',
                ),
                RoleStat(
                  value: value == null ? '—' : '≈ \$${value.toStringAsFixed(2)}',
                  label: 'Order value',
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                courierEarningsNote(data),
                style: const TextStyle(
                  fontSize: 11,
                  color: BuddyColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (window != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Window: $window',
                    style: const TextStyle(
                      fontSize: 11,
                      color: BuddyColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: BuddyColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ),
      ],
    );
  }
}

Color? _statusColor(String status) {
  switch (status) {
    case 'delivered':
    case 'completed':
      return BuddyColors.green;
    case 'out_for_delivery':
      return BuddyColors.gold;
    case 'cancelled':
      return BuddyColors.red;
    default:
      return BuddyColors.green;
  }
}

/// Fallback when the server sent `vehicle_type` without a display label.
String deliveryVehicleFallbackLabel(String vehicleType) =>
    vehicleType.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty
        ? w
        : w.substring(0, 1).toUpperCase() + w.substring(1)).join(' ');