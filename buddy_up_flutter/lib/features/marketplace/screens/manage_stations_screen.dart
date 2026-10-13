import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../../gym/providers/gym_provider.dart';
import '../providers/marketplace_provider.dart';
import '../providers/station_application_provider.dart';
import '../utils/organiser.dart';
import '../utils/stations.dart';
import 'station_application_screen.dart' show DayHours;

/// Manage the pickup stations you run, and apply to run another.
///
/// `GET /marketplace/stations/` is the public list a buyer picks from, so it is
/// also what this screen reads — there is no "my stations" endpoint. Ownership
/// is therefore *derived* from the rows themselves: each one names its owner
/// (`owner_type` plus a `shop` or `gym` id), and the screen narrows that list
/// against the caller's own shops and the gyms they own or co-own. Nothing here
/// trusts the caller: a station whose owner is not recognised is excluded, not
/// included.
///
/// The guard that actually runs server-side is `_can_manage_station` — an owner
/// or manager of the shop, an owner or co-owner of the gym.
class ManageStationsScreen extends ConsumerWidget {
  const ManageStationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsAsync = ref.watch(stationsProvider(const StationQuery()));
    final shops = ref.watch(myShopsProvider).value ?? const <Shop>[];
    final ownedGyms = ref.watch(ownedGymsProvider).value ?? const <OwnedGym>[];

    return RoleDashboardShell(
      title: 'Pickup stations',
      subtitle: 'Collection points you run',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'New station',
          onPressed: () => _openEditor(context, ref, null),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(stationsProvider),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(stationsProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const RoleSectionTitle('Your stations'),
            stationsAsync.when(
              loading: () => const PageLoader(fullScreen: false),
              error: (error, _) => RoleCard(
                child: Text(
                  isStationsUnavailable(error)
                      ? 'Pickup stations are not available on this server yet.'
                      : apiErrorMessage(
                          error,
                          fallback: 'Could not load pickup stations.',
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.error,
                    height: 1.35,
                  ),
                ),
              ),
              data: (all) {
                final owned = deriveOwnedStations(
                  all,
                  shopIds: shops.map((shop) => shop.id).toSet(),
                  gymIds: ownedGyms.map((gym) => gym.id).toSet(),
                );
                if (owned.isEmpty) {
                  return RoleCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.storefront_outlined,
                            color: BuddyColors.textSecondary, size: 28),
                        const SizedBox(height: 10),
                        Text(
                          all.isEmpty
                              ? 'No pickup stations exist yet.'
                              : 'You do not own any of the stations on this '
                                  'server yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: BuddyColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => _openEditor(context, ref, null),
                          child: const Text('Create your first station'),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final station in owned)
                      _StationCard(
                        station: station,
                        onTap: () => _openEditor(context, ref, station),
                      ),
                  ],
                );
              },
            ),
            const RoleSectionTitle('Run a station elsewhere'),
            const _ApplicationCard(),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, WidgetRef ref, PickupStation? station) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _StationEditorSheet(
        station: station,
        onSaved: () => ref.invalidate(stationsProvider),
      ),
    );
  }
}

/// Application status.
///
/// `POST /marketplace/station-applications/` is the only place the caller can
/// read a status back — there is no read endpoint — so this renders whatever the
/// wizard last recorded, and otherwise offers the application itself.
class _ApplicationCard extends ConsumerWidget {
  const _ApplicationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref.watch(stationApplicationProvider);
    final app = application;

    if (app == null) {
      return RoleCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Own a shop or gym but need a collection point somewhere else? '
              'Apply to run one — an admin reviews each application.',
              style: TextStyle(
                fontSize: 12,
                color: BuddyColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/marketplace/stations/apply'),
              icon: const Icon(Icons.how_to_reg, size: 16),
              label: const Text('Apply to become a station'),
            ),
          ],
        ),
      );
    }

    final status = stationApplicationStatusLabel(app.status);
    return RoleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Application status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              BuddyBadge(
                label: status,
                color: isPendingApplicationStatus(app.status)
                    ? BuddyColors.gold
                    : status == 'approved'
                        ? BuddyColors.green
                        : BuddyColors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stationApplicationHint(
              status: app.status,
              rejectionReason: app.rejectionReason,
            ),
            style: const TextStyle(
              fontSize: 12,
              color: BuddyColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.push('/marketplace/stations/apply'),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Update my application'),
          ),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final PickupStation station;
  final VoidCallback onTap;

  const _StationCard({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RoleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            station.isActive ? Icons.store : Icons.storefront,
            color: station.isActive ? BuddyColors.green : cs.onSurfaceVariant,
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
                        station.name.isEmpty ? 'Unnamed station' : station.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (station.isPrimary) ...[
                      const SizedBox(width: 6),
                      const BuddyBadge(
                          label: 'Primary', color: BuddyColors.gold),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stationAreaLabel(station),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                Text(
                  stationOpeningHoursLabel(station.openingHours),
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      station.ownerType == 'gym' ? 'Gym owned' : 'Shop owned',
                      style: const TextStyle(
                        fontSize: 11,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                    if ((station.phone ?? '').trim().isNotEmpty) ...[
                      const Text(' · ',
                          style: TextStyle(
                              fontSize: 11, color: BuddyColors.textSecondary)),
                      Text(
                        station.phone!.trim(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: BuddyColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 16, color: BuddyColors.textSecondary),
        ],
      ),
    );
  }
}

/// Create or edit one station.
///
/// The owner is chosen on creation and then locked, because the API rejects it:
/// a station's `shop`, `gym` and `owner_type` are immutable after creation —
/// re-parenting would silently move a public collection point and every order
/// pointing at it — so this sheet never offers them on an edit.
class _StationEditorSheet extends ConsumerStatefulWidget {
  final PickupStation? station;
  final VoidCallback onSaved;

  const _StationEditorSheet({required this.station, required this.onSaved});

  @override
  ConsumerState<_StationEditorSheet> createState() =>
      _StationEditorSheetState();
}

class _StationEditorSheetState extends ConsumerState<_StationEditorSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  late Map<String, DayHours> _hours;
  late bool _isActive;
  late bool _isPrimary;
  String? _shopId;
  String? _gymId;
  bool _saving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final station = widget.station;
    _nameController.text = station?.name ?? '';
    _addressController.text = station?.address ?? '';
    _cityController.text = station?.city ?? '';
    _countryController.text = station?.country ?? '';
    _phoneController.text = station?.phone ?? '';
    _instructionsController.text = station?.instructions ?? '';
    _latitudeController.text = station?.latitude?.toString() ?? '';
    _longitudeController.text = station?.longitude?.toString() ?? '';
    _isActive = station?.isActive ?? true;
    _isPrimary = station?.isPrimary ?? false;
    _shopId = station?.shop;
    _gymId = station?.gym;
    _hours = _parseHours(station?.openingHours);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  /// Inverse of `stationOpeningHoursLabel`: the API stores
  /// `{monday: {open, close}}`, and a plain string per day is tolerated too.
  static Map<String, DayHours> _parseHours(Map<String, dynamic>? hours) {
    final out = <String, DayHours>{};
    for (final day in stationDayKeys) {
      out[day] = (
        open: true,
        from: const TimeOfDay(hour: 8, minute: 0),
        to: const TimeOfDay(hour: 20, minute: 0)
      );
    }
    if (hours == null) return out;
    hours.forEach((key, value) {
      if (!stationDayKeys.contains(key)) return;
      final current = out[key]!;
      if (value is String) {
        final parts = value.split('-');
        final from = _parseHhmm(parts.first);
        final to = parts.length > 1 ? _parseHhmm(parts.last) : from;
        out[key] = (from != null && to != null)
            ? (open: true, from: from, to: to)
            : (open: false, from: current.from, to: current.to);
        return;
      }
      if (value is Map && value['closed'] == true) {
        out[key] = (open: false, from: current.from, to: current.to);
        return;
      }
      if (value is Map) {
        final from = _parseHhmm(value['open']);
        final to = _parseHhmm(value['close']);
        if (from == null || to == null) return;
        out[key] = (open: true, from: from, to: to);
      }
    });
    return out;
  }

  static TimeOfDay? _parseHhmm(Object? raw) {
    if (raw is! String) return null;
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  static String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _serverError = 'Give the station a name.');
      return;
    }
    if (widget.station == null && _shopId == null && _gymId == null) {
      setState(() => _serverError =
          'A station needs exactly one owner: pick a shop or a gym.');
      return;
    }
    final hours = <String, dynamic>{};
    _hours.forEach((day, value) {
      if (!value.open) return;
      hours[day] = {'open': _hhmm(value.from), 'close': _hhmm(value.to)};
    });

    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());
    final hasLatText = _latitudeController.text.trim().isNotEmpty;
    final hasLngText = _longitudeController.text.trim().isNotEmpty;
    if ((hasLatText || hasLngText) && (lat == null || lng == null)) {
      setState(() =>
          _serverError = 'Latitude and longitude must both be valid numbers.');
      return;
    }

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'phone': _phoneController.text.trim(),
      'instructions': _instructionsController.text.trim(),
      'opening_hours': hours,
      'is_active': _isActive,
      'is_primary': _isPrimary,
      if (lat != null && lng != null) 'latitude': lat,
      if (lat != null && lng != null) 'longitude': lng,
      // The owner is only sent on create: the API rejects `shop`, `gym` and
      // `owner_type` on a PATCH because re-parenting a collection point would
      // silently move every order pointing at it.
      if (widget.station == null && _shopId != null) 'shop': _shopId,
      if (widget.station == null && _gymId != null) 'gym': _gymId,
    };

    setState(() {
      _saving = true;
      _serverError = null;
    });
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final existing = widget.station;
      final raw = existing == null
          ? await repo.createStation(payload)
          : await repo.updateStation(existing.id, payload);
      widget.onSaved();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${raw['message'] ?? 'Station saved.'}')),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _serverError =
            apiErrorMessage(e, fallback: 'Could not save this station.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.station != null;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(isEdit ? 'Edit station' : 'New pickup station',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          if (!isEdit) _ownerSection(),
          _Field(label: 'Name', hint: 'e.g. Level 2, Westlands Mall', controller: _nameController),
          const SizedBox(height: 12),
          _Field(label: 'Street address', controller: _addressController),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Field(label: 'City', controller: _cityController)),
              const SizedBox(width: 10),
              Expanded(child: _Field(label: 'Country', controller: _countryController)),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Collection instructions',
            hint: 'Buzz 4B at the east gate',
            controller: _instructionsController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Field(
                  label: 'Latitude',
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(
                  label: 'Longitude',
                  controller: _longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Opening hours',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final day in stationDayKeys)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HoursRow(
                label: stationDayLabels[day] ?? day,
                value: _hours[day]!,
                onChanged: (value) => setState(() => _hours[day] = value),
              ),
            ),
          SwitchListTile(
            value: _isActive,
            activeThumbColor: BuddyColors.green,
            contentPadding: EdgeInsets.zero,
            title: const Text('Active', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              'An inactive station is hidden from buyers and rejected at checkout.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            onChanged: (v) => setState(() => _isActive = v),
          ),
          SwitchListTile(
            value: _isPrimary,
            activeThumbColor: BuddyColors.green,
            contentPadding: EdgeInsets.zero,
            title: const Text('Primary', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              'One per owner. Re-marking an existing primary is a 400.',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            onChanged: (v) => setState(() => _isPrimary = v),
          ),
          if (_serverError != null) ...[
            const SizedBox(height: 12),
            RoleNotice(message: _serverError!, isError: true),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: BuddyColors.green,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEdit ? 'Save station' : 'Create station',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Only the caller's *own* businesses are offered as owners — the backend
  /// answers 403 for anything else, and offering it would only produce a
  /// confusing rejection after the fact.
  Widget _ownerSection() {
    final shops = ref.watch(myShopsProvider).value ?? const <Shop>[];
    final gyms = ref.watch(ownedGymsProvider).value ?? const <OwnedGym>[];
    final hasOwner = shops.isNotEmpty || gyms.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (!hasOwner)
          const Text(
            'You need a shop or a gym before you can own a pickup station.',
            style: TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final shop in shops)
                ChoiceChip(
                  label: Text(shop.name, style: const TextStyle(fontSize: 12)),
                  selected: _shopId == shop.id,
                  onSelected: (v) => setState(() {
                    _shopId = v ? shop.id : null;
                    _gymId = null;
                  }),
                ),
              for (final gym in gyms)
                ChoiceChip(
                  label: Text(gym.name, style: const TextStyle(fontSize: 12)),
                  avatar: const Icon(Icons.fitness_center,
                      size: 14, color: BuddyColors.green),
                  selected: _gymId == gym.id,
                  onSelected: (v) => setState(() {
                    _gymId = v ? gym.id : null;
                    _shopId = null;
                  }),
                ),
            ],
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const _Field({
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String label;
  final DayHours value;
  final ValueChanged<DayHours> onChanged;

  const _HoursRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context, bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? value.from : value.to,
    );
    if (picked == null) return;
    onChanged(isFrom
        ? (open: value.open, from: picked, to: value.to)
        : (open: value.open, from: value.from, to: picked));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Switch(
              value: value.open,
              activeThumbColor: BuddyColors.green,
              onChanged: (v) => onChanged((
                open: v,
                from: value.from,
                to: value.to,
              )),
            ),
          ),
          if (value.open)
            TextButton(
                onPressed: () => _pick(context, true),
                child: Text(value.from.format(context))),
          if (value.open) const Text('–'),
          if (value.open)
            TextButton(
                onPressed: () => _pick(context, false),
                child: Text(value.to.format(context))),
          if (!value.open)
            Text('Closed',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}