import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/gym.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/input.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../gym/providers/gym_provider.dart';
import '../providers/marketplace_provider.dart';
import '../utils/stations.dart';
import 'station_application_screen.dart' show DayHours;

/// Manage the pickup stations you own.
///
/// `GET /marketplace/stations/` is the public list a buyer picks from, so it is
/// also what this screen reads: the caller's own stations are the rows whose
/// `shop` / `gym` id is one of theirs. There is no "my stations" endpoint, so
/// the narrowing happens here rather than being invented server-side.
///
/// Editing is restricted to what the API accepts. `shop`, `gym` and
/// `owner_type` are locked after creation — re-parenting would silently move a
/// public collection point and every order pointing at it — so this screen never
/// offers them.
class ManageStationsScreen extends ConsumerStatefulWidget {
  const ManageStationsScreen({super.key});

  @override
  ConsumerState<ManageStationsScreen> createState() =>
      _ManageStationsScreenState();
}

class _ManageStationsScreenState extends ConsumerState<ManageStationsScreen> {
  final _gymHandleController = TextEditingController();
  String? _gymId;
  bool _resolvingGym = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
  }

  @override
  void dispose() {
    _gymHandleController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    await ref.read(stationsProvider(const StationQuery()).future);
  }

  Future<void> _resolveGym() async {
    final handle = _gymHandleController.text.trim();
    if (handle.isEmpty) return;
    setState(() {
      _resolvingGym = true;
      _gymId = null;
    });
    try {
      final raw = await ref.read(gymRepositoryProvider).getGym(handle);
      if (!mounted) return;
      final gym = Gym.fromJson(raw['data'] as Map<String, dynamic>);
      setState(() => _gymId = gym.id);
      await _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apiErrorMessage(
              e,
              fallback: 'Could not find a gym with that handle.',
            )),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resolvingGym = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(myShopsProvider);
    final stations = ref.watch(stationsProvider(const StationQuery()));
    final shopIds = (shops.value ?? const <Shop>[]).map((s) => s.id).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(stationsProvider),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => context.push('/marketplace/stations/apply'),
            icon: const Icon(Icons.how_to_reg, size: 18),
            label: const Text('Apply to become a station'),
          ),
          FloatingActionButton.extended(
            backgroundColor: BuddyColors.green,
            foregroundColor: Colors.black,
            onPressed: () => _openStationEditor(context, null),
            icon: const Icon(Icons.add),
            label: const Text('Add station'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: BuddyColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stations for your ${shopIds.isEmpty && _gymId == null ? 'shops and gym' : _gymId == null ? 'shops' : 'gym'}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BuddyColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: BuddyInput(
                        hint: 'Or filter by gym handle',
                        controller: _gymHandleController,
                        suffixIcon: Icons.search,
                        onSuffixTap: _resolveGym,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_gymId != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Show my shops instead',
                        onPressed: () => setState(() {
                          _gymId = null;
                          _gymHandleController.clear();
                          _reload();
                        }),
                      ),
                  ],
                ),
                if (_resolvingGym)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: stations.when(
              loading: () => const PageLoader(fullScreen: false),
              error: (e, _) => ErrorView(
                message: apiErrorMessage(
                  e,
                  fallback: 'Could not load pickup stations.',
                ),
                onRetry: () => ref.invalidate(stationsProvider),
              ),
              data: (all) {
                final mine = all
                    .where((s) =>
                        (s.shop != null && shopIds.contains(s.shop)) ||
                        (_gymId != null && s.gym == _gymId))
                    .toList();
                if (mine.isEmpty) {
                  return const EmptyState(
                    icon: Icons.store_outlined,
                    title: 'No stations yet',
                    subtitle: 'Add a collection point so buyers can pick up '
                        'orders from you.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mine.length,
                  itemBuilder: (_, i) => _StationCard(
                    station: mine[i],
                    onTap: () => _openStationEditor(context, mine[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openStationEditor(BuildContext context, PickupStation? station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _StationEditorSheet(
        station: station,
        onSaved: () {
          ref.invalidate(stationsProvider);
        },
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
    return Card(
      color: cs.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          station.isActive ? Icons.store : Icons.storefront,
          color: station.isActive ? BuddyColors.green : cs.onSurfaceVariant,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                station.name.isEmpty ? 'Pickup station' : station.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (station.isPrimary) ...[
              const SizedBox(width: 6),
              const Text('PRIMARY',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: BuddyColors.gold)),
            ],
            if (!station.isActive) ...[
              const SizedBox(width: 6),
              const Text('INACTIVE',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: BuddyColors.red)),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stationAreaLabel(station),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            Text(
              stationOpeningHoursLabel(station.openingHours),
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

/// Create or edit one station.
///
/// The owner is chosen on creation and then locked, because the API rejects it:
/// a station's `shop`, `gym` and `owner_type` are immutable after creation.
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
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  final TextEditingController _gymHandleController = TextEditingController();

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
    _descriptionController.text = station?.description ?? '';
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
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _gymHandleController.dispose();
    super.dispose();
  }

  /// Inverse of `stationOpeningHoursLabel`: the API stores
  /// `{monday: {open, close}}`, and a plain string per day is tolerated too.
  static Map<String, DayHours> _parseHours(Map<String, dynamic>? hours) {
    final out = <String, DayHours>{};
    for (final day in stationDayKeys) {
      out[day] = (open: true, from: const TimeOfDay(hour: 8, minute: 0), to: const TimeOfDay(hour: 20, minute: 0));
    }
    if (hours == null) return out;
    hours.forEach((key, value) {
      if (!stationDayKeys.contains(key)) return;
      if (value is String) {
        final parts = value.split('-');
        final from = _parseHhmm(parts.first);
        final to = parts.length > 1 ? _parseHhmm(parts.last) : from;
        final current = out[key]!;
        if (from != null && to != null) {
          out[key] = (open: true, from: from, to: to);
        } else {
          out[key] = (open: false, from: current.from, to: current.to);
        }
        return;
      }
      if (value is Map && value['closed'] == true) {
        final current = out[key]!;
        out[key] = (open: false, from: current.from, to: current.to);
        return;
      }
      if (value is Map) {
        final from = _parseHhmm(value['open'] as String?);
        final to = _parseHhmm(value['close'] as String?);
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
    if ((lat == null || lng == null) &&
        (_latitudeController.text.trim().isNotEmpty ||
            _longitudeController.text.trim().isNotEmpty)) {
      setState(() =>
          _serverError = 'Latitude and longitude must both be valid numbers.');
      return;
    }

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
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
        SnackBar(content: Text(raw['message'] as String? ?? 'Station saved.')),
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
          BuddyInput(
            label: 'Name',
            hint: 'e.g. Level 2, Westlands Mall',
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Description (optional)',
            controller: _descriptionController,
          ),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Street address',
            controller: _addressController,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BuddyInput(
                    label: 'City', controller: _cityController),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BuddyInput(
                    label: 'Country', controller: _countryController),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BuddyInput(
            label: 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          BuddyInput(
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
                child: BuddyInput(
                  label: 'Latitude',
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BuddyInput(
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
          const SizedBox(height: 8),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BuddyColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BuddyColors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                _serverError!,
                style:
                    const TextStyle(fontSize: 12, color: BuddyColors.red, height: 1.35),
              ),
            ),
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

  Widget _ownerSection() {
    final shops = ref.watch(myShopsProvider).value ?? const <Shop>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Owner',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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
          ],
        ),
        const SizedBox(height: 8),
        BuddyInput(
          label: '…or a gym handle you own',
          controller: _gymHandleController,
          suffixIcon: Icons.search,
          onSuffixTap: () async {
            final handle = _gymHandleController.text.trim();
            if (handle.isEmpty) return;
            try {
              final raw = await ref.read(gymRepositoryProvider).getGym(handle);
              final gym = Gym.fromJson(raw['data'] as Map<String, dynamic>);
              if (mounted) {
                setState(() {
                  _gymId = gym.id;
                  _shopId = null;
                });
              }
            } catch (e) {
              if (mounted) {
                setState(() => _serverError = apiErrorMessage(
                      e,
                      fallback: 'Could not resolve that gym.',
                    ));
              }
            }
          },
        ),
        if (_gymId != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Gym owner: $_gymId',
              style: const TextStyle(fontSize: 11, color: BuddyColors.green),
            ),
          ),
      ],
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

/// Convenience so the "apply for a station" screen is reachable from here too.
class StationApplicationLauncher extends StatelessWidget {
  const StationApplicationLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return BuddyButtonLike(onTap: () => context.push('/marketplace/stations/apply'));
  }
}

class BuddyButtonLike extends StatelessWidget {
  final VoidCallback onTap;

  const BuddyButtonLike({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.how_to_reg, size: 18),
      label: const Text('Apply to become a station'),
    );
  }
}