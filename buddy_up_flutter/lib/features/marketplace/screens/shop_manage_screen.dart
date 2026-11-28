import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/gym_link_requests_panel.dart';

/// Shop management console.
///
/// Mirrors the web's `/marketplace/shops/:handle/manage`: a privileged
/// operator shell with deep-linkable tabs for Overview / Team / Gym requests.
/// Any operator in the roster gets read-only panels; write actions are gated
/// on `my_role == 'owner'` — managers can't invite/promote/remove people.
class ShopManageScreen extends ConsumerStatefulWidget {
  final String handle;
  final String? initialTab;

  const ShopManageScreen({super.key, required this.handle, this.initialTab});

  static const tabs = ['Overview', 'Inventory', 'Team', 'Gym requests'];

  @override
  ConsumerState<ShopManageScreen> createState() => _ShopManageScreenState();
}

class _ShopManageScreenState extends ConsumerState<ShopManageScreen> {
  late int _tabIndex = widget.initialTab == 'team'
      ? 2
      : widget.initialTab == 'gym-links'
          ? 3
          : 0;
  String? _actionError;
  String? _notice;
  String? _busyKey;

  final _inviteController = TextEditingController();
  String _inviteRole = 'staff';

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  bool _canManage(String role) => role == 'owner';

  bool _isOperator(String role) => const {'owner', 'manager', 'staff'}.contains(role);

  @override
  Widget build(BuildContext context) {
    final shopAsync = ref.watch(shopManageProvider(widget.handle));

    return shopAsync.when(
      loading: () => const RoleDashboardShell(title: 'Manage shop', body: PageLoader()),
      error: (error, _) => RoleDashboardShell(
        title: 'Manage shop',
        body: ErrorView(
          message: 'Could not load this shop.',
          onRetry: () => ref.invalidate(shopManageProvider(widget.handle)),
        ),
      ),
      data: (shop) => _buildConsole(context, shop),
    );
  }

  Widget _buildConsole(BuildContext context, Shop shop) {
    final myRole = shop.myRole.isEmpty ? '' : shop.myRole;
    final canManage = _canManage(myRole);
    final isOperator = _isOperator(myRole);

    return RoleDashboardShell(
      title: shop.name.isEmpty ? shop.handle : shop.name,
      subtitle: 'Manage @${shop.handle}',
      actions: [
        IconButton(
          icon: const Icon(Icons.open_in_new, size: 18),
          tooltip: 'View shop',
          onPressed: () => context.push('/marketplace/shops/${shop.handle}'),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shopManageProvider(widget.handle));
          ref.invalidate(shopGymLinksProvider(widget.handle));
          ref.invalidate(shopGymLinksProvider(null));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            if (!isOperator)
              const RoleNotice(
                message: 'You are not a member of this shop, so management actions are limited.',
              ),
            if (_actionError != null) RoleNotice(message: _actionError!, isError: true),
            if (_notice != null) RoleNotice(message: _notice!),
            RoleFilterChips<String>(
              options: ShopManageScreen.tabs,
              selected: ShopManageScreen.tabs[_tabIndex],
              label: (tab) => tab,
              onSelected: (tab) => setState(() => _tabIndex = ShopManageScreen.tabs.indexOf(tab)),
            ),
            const SizedBox(height: 16),
            switch (_tabIndex) {
              0 => _OverviewTab(shop: shop, canManage: canManage),
              1 => _InventoryTab(handle: shop.handle, canManage: canManage),
              2 => _TeamTab(
                  shop: shop,
                  canManage: canManage,
                  busyKey: _busyKey,
                  inviteController: _inviteController,
                  inviteRole: _inviteRole,
                  onInviteRoleChanged: (r) => setState(() => _inviteRole = r),
                  onInvite: _invite,
                  onToggleRole: _toggleRole,
                  onRemove: _removeMember,
                ),
              _ => GymLinkRequestsPanel(shopHandle: shop.handle),
            },
          ],
        ),
      ),
    );
  }

  Future<void> _invite() async {
    final target = _inviteController.text.trim().replaceFirst('@', '');
    if (target.isEmpty) return;
    setState(() {
      _actionError = null;
      _notice = null;
      _busyKey = 'invite';
    });
    try {
      await ref
          .read(shopManageActionsProvider)
          .addMember(widget.handle, target, _inviteRole);
      setState(() {
        _notice = 'Invite sent to $target.';
        _inviteController.clear();
      });
    } catch (e) {
      setState(() => _actionError = _message(e));
    } finally {
      setState(() => _busyKey = null);
    }
  }

  Future<void> _toggleRole(ShopMember member) async {
    final before = member.role;
    final after = before == 'staff' ? 'manager' : 'staff';
    final username = member.profileData?['username']?.toString() ?? '';
    if (username.isEmpty) {
      setState(() => _actionError = 'That member has no username on record.');
      return;
    }
    setState(() {
      _busyKey = member.id;
      _actionError = null;
      _notice = null;
    });
    try {
      await ref.read(shopManageActionsProvider).addMember(widget.handle, username, after);
      setState(() => _notice = '$username is now a $after.');
    } catch (e) {
      setState(() => _actionError = _message(e));
    } finally {
      setState(() => _busyKey = null);
    }
  }

  Future<void> _removeMember(ShopMember member) async {
    final username = member.profileData?['username']?.toString() ?? '';
    if (username.isEmpty) {
      setState(() => _actionError = 'That member has no username on record.');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: BuddyColors.surface,
        title: const Text('Remove member',
            style: TextStyle(color: BuddyColors.textPrimary)),
        content: Text(
          'Remove @$username from this shop? They lose access immediately.',
          style: const TextStyle(color: BuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: BuddyColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove', style: TextStyle(color: BuddyColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _busyKey = member.id;
      _actionError = null;
      _notice = null;
    });
    try {
      await ref.read(shopManageActionsProvider).removeMember(widget.handle, username);
      setState(() => _notice = '$username removed.');
    } catch (e) {
      setState(() => _actionError = _message(e));
    } finally {
      setState(() => _busyKey = null);
    }
  }

  String _message(Object error) {
    if (error is Exception) {
      final msg = error.toString();
      const prefix = 'Exception:';
      return msg.startsWith(prefix) ? msg.substring(prefix.length).trim() : msg;
    }
    return 'Action failed.';
  }
}

class _OverviewTab extends StatelessWidget {
  final Shop shop;
  final bool canManage;

  const _OverviewTab({required this.shop, required this.canManage});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _Stat(label: 'Products', value: shop.productCount.toString(), icon: Icons.inventory_2_outlined),
      _Stat(label: 'Programmes', value: shop.programmeCount.toString(), icon: Icons.fitness_center_outlined),
      _Stat(label: 'Meal plans', value: shop.mealPlanCount.toString(), icon: Icons.restaurant_outlined),
      _Stat(label: 'Events', value: shop.eventCount.toString(), icon: Icons.event_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Overview'),
        Row(
          children: [
            for (final row in rows.take(2)) ...[
              Expanded(child: _StatTile(stat: row)),
              const SizedBox(width: 10),
            ],
            Expanded(child: _StatTile(stat: rows[2])),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(stat: rows[3])),
          ],
        ),
        const SizedBox(height: 10),
        if (canManage) ...[
          const RoleSectionTitle('Manage catalogue'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.push('/marketplace/products/create'),
                icon: const Icon(Icons.inventory_2_outlined, size: 17),
                label: const Text('Add product'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/marketplace/programmes/create'),
                icon: const Icon(Icons.fitness_center_outlined, size: 17),
                label: const Text('Add programme'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/marketplace/meal-plans/create'),
                icon: const Icon(Icons.restaurant_outlined, size: 17),
                label: const Text('Add meal plan'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/marketplace/events/create?shop=${Uri.encodeComponent(shop.handle)}',
                ),
                icon: const Icon(Icons.event_outlined, size: 17),
                label: const Text('Add event'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        const Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: BuddyColors.textSecondary),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Shop\u2019s sales are visible in gym revenue tabs once a gym link is approved.',
                style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;

  const _Stat({required this.label, required this.value, required this.icon});
}

class _StatTile extends StatelessWidget {
  final _Stat stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, size: 14, color: BuddyColors.green),
          const SizedBox(height: 6),
          Text(stat.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(stat.label,
              style: const TextStyle(fontSize: 9, color: BuddyColors.textSecondary)),
        ],
      ),
    );
  }
}

class _InventoryTab extends ConsumerStatefulWidget {
  final String handle;
  final bool canManage;

  const _InventoryTab({required this.handle, required this.canManage});

  @override
  ConsumerState<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<_InventoryTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(shopInventoryProvider((handle: widget.handle, query: _query)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Inventory'),
        Text(
          widget.canManage
              ? 'Update stock quantities with an audit reason. Checkout reservations remain server-controlled.'
              : 'Current stock levels for this shop.',
          style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.qr_code_scanner),
            hintText: 'Search by barcode or product name',
            isDense: true,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 10),
        inventory.when(
          loading: () => const PageLoader(fullScreen: false),
          error: (error, _) => RoleNotice(
            message: 'Could not load inventory: $error',
            isError: true,
          ),
          data: (products) => products.isEmpty
              ? const RoleCard(child: Text('No products are attached to this shop yet.'))
              : Column(
                  children: [
                    for (final product in products)
                      _InventoryRow(
                        product: product,
                        canManage: widget.canManage,
                        onSave: (quantity, tracking, reason) async {
                          await ref.read(shopManageActionsProvider).adjustInventory(
                                widget.handle,
                                product.id,
                                quantity: quantity,
                                trackingEnabled: tracking,
                                reason: reason,
                              );
                        },
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _InventoryRow extends StatefulWidget {
  final MarketplaceProduct product;
  final bool canManage;
  final Future<void> Function(int quantity, bool tracking, String reason) onSave;

  const _InventoryRow({required this.product, required this.canManage, required this.onSave});

  @override
  State<_InventoryRow> createState() => _InventoryRowState();
}

class _InventoryRowState extends State<_InventoryRow> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final color = !product.stockTrackingEnabled
        ? BuddyColors.textSecondary
        : product.stockQuantity == 0
            ? BuddyColors.red
            : product.stockQuantity <= 5
                ? BuddyColors.gold
                : BuddyColors.green;
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  product.stockTrackingEnabled ? '${product.stockQuantity} in stock' : 'Stock tracking off',
                  style: TextStyle(fontSize: 12, color: color),
                ),
                if (_error != null)
                  Text(_error!, style: const TextStyle(fontSize: 11, color: BuddyColors.red)),
              ],
            ),
          ),
          if (widget.canManage)
            OutlinedButton(
              onPressed: _busy ? null : _edit,
              child: Text(_busy ? 'Saving…' : 'Edit'),
            ),
        ],
      ),
    );
  }

  Future<void> _edit() async {
    final quantity = TextEditingController(text: '${widget.product.stockQuantity}');
    final reason = TextEditingController();
    var tracking = widget.product.stockTrackingEnabled;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Update ${widget.product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: reason,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Reason (optional)'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: tracking,
                title: const Text('Track stock'),
                onChanged: (value) => setDialogState(() => tracking = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (result != true || !mounted) return;
    final parsed = int.tryParse(quantity.text.trim());
    if (parsed == null || parsed < 0) {
      setState(() => _error = 'Enter a whole number of zero or more.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSave(parsed, tracking, reason.text);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _TeamTab extends StatelessWidget {
  final Shop shop;
  final bool canManage;
  final String? busyKey;
  final TextEditingController inviteController;
  final String inviteRole;
  final ValueChanged<String> onInviteRoleChanged;
  final VoidCallback onInvite;
  final ValueChanged<ShopMember> onToggleRole;
  final ValueChanged<ShopMember> onRemove;

  const _TeamTab({
    required this.shop,
    required this.canManage,
    required this.busyKey,
    required this.inviteController,
    required this.inviteRole,
    required this.onInviteRoleChanged,
    required this.onInvite,
    required this.onToggleRole,
    required this.onRemove,
  });

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return BuddyColors.gold;
      case 'manager':
        return BuddyColors.blue;
      default:
        return BuddyColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = shop.members;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RoleSectionTitle('Team'),
        const SizedBox(height: 4),
        if (canManage) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inviteController,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'username',
                    isDense: true,
                    labelText: 'Invite username',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: inviteRole,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'manager', child: Text('Manager')),
                ],
                onChanged: (value) {
                  if (value != null) onInviteRoleChanged(value);
                },
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: busyKey == 'invite' ? null : onInvite,
                child: busyKey == 'invite'
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (members.isEmpty)
          const Text('Just you so far.',
              style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
        for (final member in members) _memberRow(member),
      ],
    );
  }

  Widget _memberRow(ShopMember member) {
    final p = member.profileData;
    final username = p?['username']?.toString() ?? '';
    final display = p?['display_name']?.toString() ?? username;
    final avatar = p?['avatar_url']?.toString();
    final isOwner = member.role == 'owner';
    final editable = canManage && !isOwner;

    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Avatar(
              src: avatar,
              alt: display,
              size: AvatarSize.sm,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  if (username.isNotEmpty)
                    Text('@$username',
                        style: const TextStyle(fontSize: 10, color: BuddyColors.textSecondary)),
                ],
              ),
            ),
            BuddyBadge(label: member.role, color: _roleColor(member.role)),
            if (editable) ...[
              const SizedBox(width: 6),
              _TeamPill(
                key: Key('shop-toggle-${member.id}'),
                icon: Icons.swap_horiz,
                label: 'Toggle',
                onPressed: busyKey == member.id ? null : () => onToggleRole(member),
              ),
              _TeamPill(
                key: Key('shop-remove-${member.id}'),
                icon: Icons.close,
                label: 'Remove',
                tint: BuddyColors.red,
                onPressed: busyKey == member.id ? null : () => onRemove(member),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeamPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? tint;
  final VoidCallback? onPressed;

  const _TeamPill({
    super.key,
    required this.icon,
    required this.label,
    this.tint,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = tint ?? BuddyColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 12, color: color),
        label: Text(label, style: TextStyle(fontSize: 10, color: color)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          minimumSize: const Size(0, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

