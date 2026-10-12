import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/governance/emails/**` — the staff→user assistance console.
///
/// This endpoint is deliberately the narrowest thing in the console: one
/// recipient, who must be a registered account, with a hard per-staff-hour
/// ceiling. The screen keeps those limits visible rather than letting an
/// operator discover them by being refused, and it never offers a bulk or cc
/// affordance because the API rejects one as a validation error — there is
/// nowhere in the schema to put a second address.
class AdminEmailScreen extends ConsumerStatefulWidget {
  const AdminEmailScreen({super.key});

  @override
  ConsumerState<AdminEmailScreen> createState() => _AdminEmailScreenState();
}

class _AdminEmailScreenState extends ConsumerState<AdminEmailScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  String _status = 'all';
  int _page = 1;

  bool _composing = false;
  final Set<String> _busyIds = {};
  String? _expandedId;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  PortalQuery get _query => PortalQuery.of(_page, {
        'status': _status,
        'recipient_email': _searchController.text.trim(),
      });

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Email')),
        body: const ErrorView(
          message: 'Staff access is required. The assistance console is not '
              'reachable from a personal account.',
        ),
      );
    }

    final log = ref.watch(emailLogProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Email')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(emailLogProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Assistance console',
              description: 'One message to one registered account. Every send '
                  'is recorded against your staff account whether or not it '
                  'arrives.',
              onRefresh: () => ref.invalidate(emailLogProvider),
              refreshing: log.isLoading,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => setState(() => _composing = !_composing),
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: BuddyColors.black,
              ),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(
                _composing ? 'Close composer' : 'Write a message',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            const AdminRuleNote(
              icon: Icons.speed,
              text: 'Ceiling: 20 queued messages per '
                  'staff account per hour, on top of a per-address limit. One '
                  'recipient per message — there is no cc and no bulk send.',
            ),
            if (_composing) ...[
              const SizedBox(height: 14),
              const _EmailComposer(),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Recipient email…',
                prefixIcon: const Icon(Icons.search, size: 18),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) {
                    setState(() {
                      _page = 1;
                      _error = null;
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            AdminFilterChips(
              value: _status,
              options: const [
                (value: 'all', label: 'Any outcome'),
                ...kEmailStatusChoices,
              ],
              onChanged: (v) => setState(() {
                _status = v;
                _page = 1;
                _error = null;
              }),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(message: _error!),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            ...log.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                    message: apiErrorMessage(e, fallback: 'Failed to load the send log.')),
              ],
              data: (page) => [
                if (page.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.outbox_outlined,
                    title: 'No messages match this filter.',
                    hint: 'The log stores a 500-character preview, never the '
                        'whole message — a full-text log would outlive the '
                        'user\'s account and every deletion request.',
                  )
                else
                  for (final entry in page.items) _logRow(entry),
                AdminPager(
                  page: page,
                  currentPage: _page,
                  busy: log.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logRow(EmailLog entry) {
    final busy = _busyIds.contains(entry.id);
    final expanded = _expandedId == entry.id;
    return AdminRowCard(
      title: entry.subject.isEmpty ? '(no subject)' : entry.subject,
      badges: [
        AdminStatusBadge(status: entry.status),
        if (entry.canResend) const AdminStatusBadge(status: 'resendable', upper: false),
      ],
      subtitle: 'to ${entry.recipientEmail.isEmpty ? '—' : entry.recipientEmail}',
      meta: 'by ${entry.sentByEmail.isEmpty ? entry.sender.label : entry.sentByEmail} · '
          '${_shortDateTime(entry.createdAt)}',
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Preview',
          icon: Icons.visibility_outlined,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : entry.id),
        ),
        // Only a failure is resendable. Re-sending a `sent` message would be a
        // duplicate the user did not ask for, and a `queued` one duplicates the
        // worker's own retry — so the button is absent rather than refused.
        AdminActionButton(
          label: 'Resend',
          icon: Icons.refresh,
          onPressed: busy || !entry.canResend ? null : () => _resend(entry),
        ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Log id', value: entry.id ?? '—'),
          AdminDataRow(label: 'Recipient', value: entry.recipient.label),
          AdminDataRow(label: 'Recipient email', value: entry.recipientEmail),
          AdminDataRow(label: 'Sender', value: entry.sentByEmail),
          AdminDataRow(label: 'Template', value: entry.templateKey),
          AdminDataRow(label: 'Queued at', value: _shortDateTime(entry.createdAt)),
          if (entry.relatedObjectType.isNotEmpty)
            AdminDataRow(
              label: 'Related',
              value: '${entry.relatedObjectType} ${entry.relatedObjectId}',
            ),
          if (entry.error.isNotEmpty) ...[
            const SizedBox(height: 6),
            AdminErrorBanner(message: 'Delivery failed: ${entry.error}'),
          ],
          if (expanded) ...[
            const SizedBox(height: 8),
            Text('Body preview',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            AdminHintNote(
              text: entry.bodyPreview.isEmpty
                  ? 'No preview was stored.'
                  : entry.bodyPreview,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resend(EmailLog entry) async {
    setState(() {
      _busyIds.add(entry.id!);
      _error = null;
      _notice = null;
    });
    try {
      final raw =
          await ref.read(adminPortalRepositoryProvider).resendStaffEmail(entry.id!);
      if (!mounted) return;
      setState(() =>
          _notice = '${portalMessage(raw, fallback: 'Requeued.')} '
              'Note: the original body was never stored, so the resend re-renders '
              'from the preview.');
      ref.invalidate(emailLogProvider);
    } catch (e) {
      if (mounted) setState(() => _error = moderationRefusal(e));
    } finally {
      if (mounted) setState(() => _busyIds.remove(entry.id));
    }
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

/// The compose form.
///
/// Addressed by `user_id` or `email`, never both — the API refuses a payload
/// carrying both, and refuses an address that matches no account. Sending by
/// typed email is therefore only useful for a *registered* address, which the
/// helper text says rather than letting the operator assume otherwise.
class _EmailComposer extends ConsumerStatefulWidget {
  const _EmailComposer();

  @override
  ConsumerState<_EmailComposer> createState() => _EmailComposerState();
}

class _EmailComposerState extends ConsumerState<_EmailComposer> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _sending = false;
  String? _error;
  String? _notice;

  /// Mirrors `StaffEmailSendSerializer.MAX_SUBJECT` / `MAX_BODY`, so the
  /// operator is stopped here rather than by a 400 after composing.
  static const int maxSubject = 300;
  static const int maxBody = 5000;

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _ready {
    final recipient = _recipientController.text.trim();
    final subject = _subjectController.text.trim();
    final body = _bodyController.text.trim();
    if (subject.isEmpty || body.isEmpty || subject.length > maxSubject) return false;
    if (body.length > maxBody) return false;
    // A UUID is a user_id; anything else with an @ is looked up by address.
    return recipient.isNotEmpty && _looksLikeUuid(recipient);
  }

  static final RegExp _uuid =
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
          r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  static bool _looksLikeUuid(String value) => _uuid.hasMatch(value);

  Future<void> _send() async {
    final recipient = _recipientController.text.trim();
    setState(() {
      _sending = true;
      _error = null;
      _notice = null;
    });
    try {
      final raw = await ref.read(adminPortalRepositoryProvider).sendStaffEmail({
        if (_looksLikeUuid(recipient))
          'user_id': recipient
        else
          'email': recipient,
        'subject': _subjectController.text.trim(),
        'body': _bodyController.text.trim(),
      });
      if (!mounted) return;
      setState(() => _notice = portalMessage(raw));
      _subjectController.clear();
      _bodyController.clear();
      ref.invalidate(emailLogProvider);
    } catch (e) {
      if (mounted) setState(() => _error = moderationRefusal(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New message', style: TextStyle(fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(
            'One recipient only. The address must belong to a registered, '
            'non-deleted account.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _recipientController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'User id or email',
              helperText: 'A UUID is sent as user_id; an address is looked up. '
                  'Provide exactly one.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _subjectController,
            maxLength: maxSubject,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyController,
            maxLines: 6,
            minLines: 4,
            maxLength: maxBody,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          if (_error != null) ...[
            AdminErrorBanner(message: _error!),
            const SizedBox(height: 10),
          ],
          if (_notice != null) ...[
            AdminNoticeBanner(message: _notice!),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: !_ready || _sending ? null : _send,
              style: FilledButton.styleFrom(
                backgroundColor: BuddyColors.green,
                foregroundColor: BuddyColors.black,
              ),
              icon: _sending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 16),
              label: const Text('Send message', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}