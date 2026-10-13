import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/badge.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../../shared/widgets/role_dashboard_shell.dart';
import '../providers/organiser_provider.dart';
import '../utils/courier.dart' show artifactsUsd;
import '../utils/organiser.dart';

/// Event organiser dashboard.
///
/// The check-in panel and the attendee table are the working surface; the event
/// list is the selector above them.
///
/// **A 403 from `events/mine/` is an expected state, not a failure.** Every
/// signed-in user may open this screen; only someone who created or hosts an
/// event gets a list. Rendering "you have not created any events" to every
/// non-organiser would be a lie, so the 403 gets its own message.
class EventOrganiserScreen extends ConsumerStatefulWidget {
  const EventOrganiserScreen({super.key});

  @override
  ConsumerState<EventOrganiserScreen> createState() =>
      _EventOrganiserScreenState();
}

class _EventOrganiserScreenState extends ConsumerState<EventOrganiserScreen> {
  final _codeController = TextEditingController();
  String? _checkInError;
  String? _checkInNotice;
  bool _checkInBusy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _invalidateAll() {
    ref.invalidate(organisedEventsProvider);
    ref.invalidate(eventStatsProvider);
    ref.invalidate(eventAttendeesProvider);
  }

  Future<void> _checkInForCode(String rawCode) async {
    final eventId = ref.read(selectedEventIdProvider);
    final code = rawCode.trim();
    if (eventId.isEmpty || code.isEmpty || _checkInBusy) return;

    setState(() {
      _checkInBusy = true;
      _checkInError = null;
      _checkInNotice = null;
    });
    try {
      final message =
          await ref.read(eventCheckInActionsProvider).checkIn(eventId, code);
      if (!mounted) return;
      setState(() {
        _checkInNotice = message;
        _codeController.clear();
      });
      _invalidateAll();
    } catch (error) {
      if (!mounted) return;
      // 404 unknown code · 409 already checked in · 400 cancelled or refunded.
      // The server's sentence names the attendee and the time, which is exactly
      // what resolves a "I scanned twice" dispute at the door.
      setState(() => _checkInError = apiErrorMessage(
            error,
            fallback: 'Check-in failed.',
          ));
    } finally {
      if (mounted) setState(() => _checkInBusy = false);
    }
  }

  Future<void> _checkOut(EventAttendee attendee) async {
    final eventId = ref.read(selectedEventIdProvider);
    final code = attendee.ticketCode.trim();
    if (eventId.isEmpty || code.isEmpty || _checkInBusy) return;

    setState(() {
      _checkInBusy = true;
      _checkInError = null;
      _checkInNotice = null;
    });
    try {
      final message =
          await ref.read(eventCheckInActionsProvider).checkOut(eventId, code);
      if (!mounted) return;
      setState(() => _checkInNotice = message);
      _invalidateAll();
    } catch (error) {
      if (!mounted) return;
      setState(() => _checkInError = apiErrorMessage(
            error,
            fallback: 'Could not reverse that check-in.',
          ));
    } finally {
      if (mounted) setState(() => _checkInBusy = false);
    }
  }

  Future<void> _copyTicketCodes(List<EventAttendee> attendees) async {
    final codes =
        attendees.map((a) => a.ticketCode.trim()).where((c) => c.isNotEmpty).toList();
    if (codes.isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: codes.join('\n')));
      if (!mounted) return;
      setState(() => _checkInNotice = 'Copied ${codes.length} ticket codes.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkInError = 'Could not copy to the clipboard.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(organisedEventsProvider);
    final selectedId = ref.watch(selectedEventIdProvider);

    return RoleDashboardShell(
      title: 'My events',
      subtitle: 'Organise, check in, and track attendance',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'New event',
          onPressed: () => context.push('/marketplace/events/create'),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: _invalidateAll,
        ),
      ],
      body: eventsAsync.when(
        loading: () => const PageLoader(),
        error: (error, _) => isOrganiserForbidden(error)
            ? _ForbiddenNotice(message: organiserForbiddenMessage(error))
            : ErrorView(
                message: apiErrorMessage(
                  error,
                  fallback: 'We could not load your events.',
                ),
                onRetry: () => ref.invalidate(organisedEventsProvider),
              ),
        data: (events) {
          if (events.isEmpty) return const _NoEvents();
          // Keep the selection valid without a second frame: if nothing is
          // selected (or the selection vanished after a refresh) take the first.
          final activeId = events.any((event) => event.id == selectedId)
              ? selectedId
              : events.first.id;
          if (activeId != selectedId) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ref.read(selectedEventIdProvider.notifier).set(activeId);
              }
            });
          }
          final selectedEvent = events.firstWhere(
            (event) => event.id == activeId,
            orElse: () => events.first,
          );
          return _OrganiserBody(
            events: events,
            selectedId: selectedEvent.id,
            selected: selectedEvent,
            codeController: _codeController,
            checkInBusy: _checkInBusy,
            checkInError: _checkInError,
            checkInNotice: _checkInNotice,
            onCheckIn: _checkInForCode,
            onCheckOut: _checkOut,
            onCopyCodes: _copyTicketCodes,
            onChanged: _invalidateAll,
          );
        },
      ),
    );
  }
}

/// The non-organiser state: a real explanation, not an empty list.
class _ForbiddenNotice extends StatelessWidget {
  final String message;

  const _ForbiddenNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Event organisers only',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: BuddyColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/marketplace/events/create'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create an event'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoEvents extends StatelessWidget {
  const _NoEvents();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RoleCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.calendar_month_outlined,
                  color: BuddyColors.textSecondary, size: 28),
              const SizedBox(height: 10),
              const Text(
                'You have not created any events yet.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/marketplace/events/create'),
                child: const Text('Create your first event'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganiserBody extends ConsumerWidget {
  final List<OrganiserEvent> events;
  final String selectedId;
  final OrganiserEvent selected;
  final TextEditingController codeController;
  final bool checkInBusy;
  final String? checkInError;
  final String? checkInNotice;
  final ValueChanged<String> onCheckIn;
  final ValueChanged<EventAttendee> onCheckOut;
  final ValueChanged<List<EventAttendee>> onCopyCodes;
  final VoidCallback onChanged;

  const _OrganiserBody({
    required this.events,
    required this.selectedId,
    required this.selected,
    required this.codeController,
    required this.checkInBusy,
    required this.checkInError,
    required this.checkInNotice,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCopyCodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(attendeeFiltersProvider);
    final attendeesAsync = ref.watch(
      eventAttendeesProvider(AttendeeQuery(selectedId, filters)),
    );

    return RefreshIndicator(
      onRefresh: () async => onChanged(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          RoleFilterChips<String>(
            options: events.map((event) => event.id).toList(),
            selected: selectedId,
            label: (id) {
              final event =
                  events.firstWhere((e) => e.id == id, orElse: () => events.first);
              return event.title.isEmpty ? 'Untitled event' : event.title;
            },
            onSelected: (id) {
              ref.read(selectedEventIdProvider.notifier).set(id);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (selected.isCancelled)
                const BuddyBadge(label: 'Cancelled', color: BuddyColors.red),
              if (!selected.isPublished && !selected.isCancelled)
                const BuddyBadge(
                    label: 'Draft', color: BuddyColors.textSecondary),
              if (selected.startDatetime.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      selected.startDatetime.split('T').first,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BuddyColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              TextButton(
                onPressed: () => context.push('/marketplace/events/${selected.id}'),
                child: const Text('View event page'),
              ),
            ],
          ),
          const RoleSectionTitle('Attendance'),
          _StatsBlock(event: selected, eventId: selectedId),
          const RoleSectionTitle('Check-in'),
          RoleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: BuddyInputField(
                        controller: codeController,
                        hint: 'Paste or type a ticket code',
                        textInputAction: TextInputAction.done,
                        onSubmitted: checkInBusy
                            ? null
                            : (value) => onCheckIn(value ?? ''),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ElevatedButton(
                        onPressed: checkInBusy
                            ? null
                            : () => onCheckIn(codeController.text),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          textStyle:
                              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: checkInBusy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Check in'),
                      ),
                    ),
                  ],
                ),
                if (checkInError != null) ...[
                  const SizedBox(height: 12),
                  RoleNotice(message: checkInError!, isError: true),
                ],
                if (checkInNotice != null) ...[
                  const SizedBox(height: 12),
                  RoleNotice(message: checkInNotice!),
                ],
              ],
            ),
          ),
          RoleSectionTitle(
            'Attendees',
            trailing: attendeesAsync.value?.isNotEmpty == true
                ? TextButton.icon(
                    onPressed: () => onCopyCodes(attendeesAsync.value!),
                    icon: const Icon(Icons.copy, size: 13),
                    label: const Text('Copy codes',
                        style: TextStyle(fontSize: 11)),
                  )
                : null,
          ),
          _AttendeeFilters(filters: filters),
          const SizedBox(height: 12),
          attendeesAsync.when(
            loading: () => const PageLoader(fullScreen: false),
            error: (error, _) => RoleNotice(
              message: apiErrorMessage(
                error,
                fallback: 'Could not load attendees.',
              ),
              isError: true,
            ),
            data: (attendees) => attendees.isEmpty
                ? const RoleCard(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(Icons.groups_outlined,
                            color: BuddyColors.textSecondary, size: 28),
                        SizedBox(height: 8),
                        Text(
                          'No attendees match these filters.',
                          style: TextStyle(
                              fontSize: 13, color: BuddyColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (final attendee in attendees)
                        _AttendeeCard(
                          attendee: attendee,
                          busy: checkInBusy,
                          onCheckIn: () =>
                              onCheckIn(attendee.ticketCode),
                          onCheckOut: () => onCheckOut(attendee),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatsBlock extends ConsumerWidget {
  final OrganiserEvent event;
  final String eventId;

  const _StatsBlock({required this.event, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(eventStatsProvider(eventId));
    final stats = statsAsync.value;
    final gross = stats == null ? null : artifactsUsd(stats.grossArtifacts);

    return Column(
      children: [
        RoleCard(
          child: RoleStatRow([
            RoleStat(
              value: '${stats?.ticketsSold ?? event.ticketsSoldCount}',
              label: 'Tickets sold',
            ),
            RoleStat(
              value: '${stats?.checkedIn ?? 0}',
              label: 'Checked in',
              valueColor: BuddyColors.green,
            ),
            RoleStat(
              // An unlimited event has no capacity; showing "0" next to
              // "spots remaining" would read as "full".
              value: (stats?.capacityIsUnlimited ?? false)
                  ? '∞'
                  : '${stats?.capacity ?? event.capacity}',
              label: 'Capacity',
            ),
            RoleStat(
              value: gross == null ? '—' : '≈ \$${gross.toStringAsFixed(2)}',
              label: 'Gross',
            ),
          ]),
        ),
        if (stats != null && stats.soldByTier.isNotEmpty)
          RoleCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOLD BY TIER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: BuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                for (final row in stats.soldByTier)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            row.tier.isEmpty ? 'General' : row.tier,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${row.count} sold',
                          style: const TextStyle(
                            fontSize: 12,
                            color: BuddyColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AttendeeFilters extends ConsumerWidget {
  final AttendeeFilters filters;

  const _AttendeeFilters({required this.filters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attendeeFiltersProvider.notifier);
    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHECK-IN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: BuddyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          RoleFilterChips<bool?>(
            options: const [null, false, true],
            selected: filters.checkedIn,
            label: (value) =>
                value == null ? 'All' : (value ? 'In' : 'Not in'),
            onSelected: notifier.setCheckedIn,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      filters.status.isEmpty ? '' : filters.status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    isDense: true,
                  ),
                  items: [
                    for (final filter in kOrganiserStatusFilters)
                      DropdownMenuItem(
                        value: filter.value,
                        child: Text(filter.label,
                            style: const TextStyle(fontSize: 13)),
                      ),
                  ],
                  onChanged: (value) => notifier.setStatus(value ?? ''),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextFormField(
                  initialValue: filters.tier,
                  onChanged: notifier.setTier,
                  decoration: const InputDecoration(
                    labelText: 'Tier',
                    hintText: 'Any tier',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendeeCard extends StatelessWidget {
  final EventAttendee attendee;
  final bool busy;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _AttendeeCard({
    required this.attendee,
    required this.busy,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final label = attendee.label;
    final canCheckIn = attendee.ticketCode.trim().isNotEmpty && !busy;

    return RoleCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              size: 16, color: BuddyColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty ? 'Attendee' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  attendee.ticketCode.isEmpty
                      ? 'No ticket code'
                      : attendee.ticketCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (attendee.tier.isNotEmpty)
            BuddyBadge(label: attendee.tier, color: BuddyColors.textSecondary),
          const SizedBox(width: 8),
          BuddyBadge(
            label: attendee.isCheckedIn ? 'In' : 'Not in',
            color: attendee.isCheckedIn
                ? BuddyColors.green
                : BuddyColors.textSecondary,
          ),
          const SizedBox(width: 4),
          if (attendee.isCheckedIn)
            IconButton(
              icon: const Icon(Icons.undo, size: 16),
              tooltip: 'Reverse check-in',
              onPressed: busy ? null : onCheckOut,
            )
          else
            IconButton(
              icon: const Icon(Icons.how_to_reg, size: 16),
              tooltip: 'Check in',
              onPressed: canCheckIn ? onCheckIn : null,
            ),
        ],
      ),
    );
  }
}

/// A plain text field for the ticket-code entry.
///
/// Deliberately not [BuddyInput]: that widget renders a label above the field
/// and is sized for a form, whereas this sits inline with a button on the same
/// row.
class BuddyInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final ValueChanged<String?>? onSubmitted;

  const BuddyInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}