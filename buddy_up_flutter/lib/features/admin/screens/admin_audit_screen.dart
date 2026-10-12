import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_portal.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/admin_provider.dart';
import '../providers/governance_provider.dart';
import '../widgets/admin_widgets.dart';

/// `/governance/audit/**` — the record of what staff actually did.
///
/// Every row is immutable and every mutation in this console writes one, so
/// this is the page an incident review is answered from. That shapes it: the
/// filter set is the operators' real questions ("what did we do to this user",
/// "what did this person do", "what happened last Tuesday"), a row expands to
/// the full before/after delta rather than a summary line, and any object can
/// be read as a timeline instead of a list.
///
/// `before` / `after` hold state deltas with secrets redacted at write time —
/// they are never message bodies — so a row can be shown verbatim.
class AdminAuditScreen extends ConsumerStatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  ConsumerState<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends ConsumerState<AdminAuditScreen> {
  final TextEditingController _actionController = TextEditingController();
  final TextEditingController _targetIdController = TextEditingController();
  final TextEditingController _actorController = TextEditingController();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _targetType = '';
  int _page = 1;

  bool _showFilters = false;
  bool _exporting = false;
  String? _expandedId;
  String? _error;
  String? _notice;
  String? _timelineFor;

  @override
  void dispose() {
    _actionController.dispose();
    _targetIdController.dispose();
    _actorController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  PortalQuery get _query => PortalQuery.of(_page, {
        'action': _actionController.text.trim(),
        'target_type': _targetType,
        'target_id': _targetIdController.text.trim(),
        'actor': _actorController.text.trim(),
        'date_from': _fromController.text.trim(),
        'date_to': _toController.text.trim(),
      });

  void _setFilter(void Function() mutate) {
    setState(() {
      mutate();
      _page = 1;
      _error = null;
      _notice = null;
    });
  }

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _error = null;
      _notice = null;
    });
    try {
      final export = await fetchAuditExport(ref, _query);
      await _shareExport(export);
      if (!mounted) return;
      setState(() => _notice =
          'Export ready: ${export.filename} (${export.bytes.length} bytes). '
          'The file holds exactly the rows this filter is showing.');
    } catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e, fallback: 'Export failed.'));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Hand the CSV to the platform share sheet.
  ///
  /// Sharing the bytes rather than opening a URL because the export route is
  /// scope-gated — launching it externally would show a login page, not a file.
  /// `XFile` comes from `share_plus`, which re-exports it, so this adds no
  /// dependency.
  Future<void> _shareExport(AuditCsvExport export) async {
    if (export.bytes.isEmpty) {
      throw const FormatException(
          'The server returned an empty export for this filter.');
    }
    await SharePlus.instance.share(
      ShareParams(
        subject: 'BuddyUp audit export',
        text: 'Audit export ${export.filename}',
        files: [
          XFile.fromData(
            export.bytes,
            mimeType: 'text/csv',
            name: export.filename,
          ),
        ],
        sharePositionOrigin: _shareOrigin(),
      ),
    );
  }

  /// iOS needs an anchor to present the share sheet from, and crashes without
  /// one on iPad. Same helper the analytics share path uses.
  Rect? _shareOrigin() {
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isStaffProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin · Audit')),
        body: const ErrorView(
          message: 'Staff access is required. The audit trail is not readable '
              'from a personal account.',
        ),
      );
    }

    final audit = ref.watch(auditLogProvider(_query));

    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Audit')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(auditLogProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AdminPageHeader(
              title: 'Audit log',
              description: 'One immutable row per mutating staff action. Rows '
                  'are never edited, and the secret fields are redacted before '
                  'the row is written.',
              onRefresh: () => ref.invalidate(auditLogProvider),
              refreshing: audit.isLoading,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                    icon: Icon(
                      _showFilters ? Icons.expand_less : Icons.tune,
                      size: 16,
                    ),
                    label: Text(
                      _showFilters ? 'Hide filters' : 'Filters',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_outlined, size: 16),
                    label: const Text('Export CSV',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
            if (_showFilters) ...[
              const SizedBox(height: 14),
              _filterPanel(),
            ],
            const SizedBox(height: 12),
            if (_error != null) ...[
              AdminErrorBanner(message: _error!),
              const SizedBox(height: 10),
            ],
            if (_notice != null) ...[
              AdminNoticeBanner(message: _notice!),
              const SizedBox(height: 10),
            ],
            ...audit.when(
              loading: () => const [AdminLoadingBlock()],
              error: (e, _) => [
                AdminErrorBanner(
                    message: apiErrorMessage(e, fallback: 'Failed to load the audit log.')),
              ],
              data: (page) => [
                Row(
                  children: [
                    Expanded(
                      child: AdminStatCard(
                          label: 'Matching rows', value: '${page.count}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AdminStatCard(
                          label: 'On this page', value: '${page.items.length}'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (page.items.isEmpty)
                  const AdminEmptyState(
                    icon: Icons.history,
                    title: 'No audit rows match these filters.',
                    hint: 'Action and target_type are matched exactly. An '
                        'empty result for a well-formed verb means it has not '
                        'happened yet.',
                  )
                else
                  for (final row in page.items) _row(row),
                AdminPager(
                  page: page,
                  currentPage: _page,
                  busy: audit.isLoading,
                  onPage: (next) => setState(() => _page = next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterPanel() {
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
          Text('Filters', style: TextStyle(fontSize: 13, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text(
            'These are the same filters the CSV export uses, so an export is '
            'always exactly the rows you are looking at.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _actionController,
            decoration: InputDecoration(
              labelText: 'Action verb',
              hintText: 'users.suspend',
              helperText: 'A dotted lowercase verb. Validated for shape, not '
                  'membership.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (_) => _setFilter(() {}),
          ),
          const SizedBox(height: 10),
          _chipsForVerbs(),
          const SizedBox(height: 12),
          AdminFilterChips(
            value: _targetType,
            options: const [
              (value: '', label: 'Any object'),
              ...kAuditTargetTypes,
            ],
            onChanged: (v) => _setFilter(() => _targetType = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetIdController,
            decoration: InputDecoration(
              labelText: 'Target id',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (_) => _setFilter(() {}),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _actorController,
            decoration: InputDecoration(
              labelText: 'Actor id',
              helperText: 'A staff user id.',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onSubmitted: (_) => _setFilter(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fromController,
                  decoration: InputDecoration(
                    labelText: 'From',
                    hintText: 'YYYY-MM-DD',
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (_) => _setFilter(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _toController,
                  decoration: InputDecoration(
                    labelText: 'To',
                    hintText: 'YYYY-MM-DD',
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onSubmitted: (_) => _setFilter(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _setFilter(() {
                  _actionController.clear();
                  _targetType = '';
                  _targetIdController.clear();
                  _actorController.clear();
                  _fromController.clear();
                  _toController.clear();
                }),
                child: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
              FilledButton(
                onPressed: () => _setFilter(() {}),
                style: FilledButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: BuddyColors.black,
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipsForVerbs() {
    final current = _actionController.text.trim();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final verb in kAuditActionShortcuts)
          InkWell(
            onTap: () => _setFilter(() {
              _actionController.text = current == verb ? '' : verb;
            }),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: current == verb
                    ? BuddyColors.green.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                verb,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: current == verb ? FontWeight.w700 : FontWeight.w400,
                  color: current == verb
                      ? BuddyColors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(AdminActionLog row) {
    final expanded = _expandedId == row.id;
    final changed = row.changedKeys;
    final badges = <Widget>[];
    if (row.targetType.isNotEmpty) {
      badges.add(AdminStatusBadge(status: row.targetType, upper: false));
    }
    if (row.ipAddress != null && row.ipAddress!.isNotEmpty) {
      badges.add(AdminStatusBadge(status: row.ipAddress!, upper: false));
    }

    return AdminRowCard(
      title: row.summary.isEmpty ? row.action : row.summary,
      badges: badges,
      subtitle: '${row.action} by ${row.actorLabel}',
      meta: '${_shortDateTime(row.createdAt)}'
          '${row.targetType.isEmpty ? '' : ' · ${row.targetType} ${row.targetId}'}',
      actions: [
        AdminActionButton(
          label: expanded ? 'Hide' : 'Detail',
          icon: Icons.visibility_outlined,
          onPressed: () =>
              setState(() => _expandedId = expanded ? null : row.id),
        ),
        if (row.targetType.isNotEmpty)
          AdminActionButton(
            label: 'Timeline',
            icon: Icons.timeline,
            onPressed: () => setState(
                () => _timelineFor = _timelineFor == row.id ? null : row.id),
          ),
      ],
      expanded: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminDataRow(label: 'Row id', value: row.id ?? '—'),
          AdminDataRow(label: 'Actor', value: row.actorLabel),
          AdminDataRow(label: 'Action', value: row.action),
          AdminDataRow(label: 'Target', value: '${row.targetType} ${row.targetId}'),
          AdminDataRow(label: 'When', value: _shortDateTime(row.createdAt)),
          if (row.requestId.isNotEmpty)
            AdminDataRow(label: 'Request id', value: row.requestId),
          if (row.userAgent.isNotEmpty)
            AdminDataRow(label: 'User agent', value: row.userAgent),
          if (expanded) ...[
            const SizedBox(height: 10),
            Text('Before / after',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 6),
            if (row.before == null && row.after == null)
              const AdminHintNote(
                  text: 'This action recorded no state delta — it changed no '
                      'field, only a status the row itself carries.')
            else if (changed.isEmpty)
              const AdminHintNote(
                  text: 'Before and after are identical: the delta is empty.')
            else
              for (final key in changed)
                _deltaLine(row, key),
          ],
          if (_timelineFor == row.id) ...[
            const SizedBox(height: 10),
            _timeline(row),
          ],
        ],
      ),
    );
  }

  /// One changed field, old value struck through against the new one.
  ///
  /// Showing the set difference rather than both blobs is the point: the
  /// question a row answers is "what moved", and the answer is the keys whose
  /// two sides disagree.
  Widget _deltaLine(AdminActionLog row, String key) {
    final cs = Theme.of(context).colorScheme;
    final before = row.valueAt(key);
    final after = row.valueAt(key, useAfter: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  before.isEmpty ? '—' : before,
                  style: TextStyle(
                      fontSize: 12,
                      color: BuddyColors.red,
                      decoration: before.isEmpty
                          ? null
                          : TextDecoration.lineThrough,
                      decorationColor: BuddyColors.red),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward,
                    size: 12, color: BuddyColors.textSecondary),
              ),
              Expanded(
                child: Text(after.isEmpty ? '—' : after,
                    style: const TextStyle(fontSize: 12, color: BuddyColors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeline(AdminActionLog row) {
    final timeline = ref.watch(auditTimelineProvider((
      targetType: row.targetType,
      targetId: row.targetId,
      page: 1,
    )));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('History of this ${row.targetType}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            Text('oldest first',
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ...timeline.when(
          loading: () => const [AdminLoadingBlock()],
          error: (e, _) => [
            AdminErrorBanner(
                message: apiErrorMessage(e, fallback: 'Could not load the timeline.')),
          ],
          data: (page) => [
            if (page.items.isEmpty)
              const AdminHintNote(text: 'Nothing has ever been done to this object.')
            else
              for (final entry in page.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3, right: 8),
                        child: Icon(Icons.circle, size: 7, color: BuddyColors.green),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.summary.isEmpty ? entry.action : entry.summary,
                                style: const TextStyle(fontSize: 12)),
                            Text(
                              '${_shortDateTime(entry.createdAt)} · ${entry.actorLabel}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ],
    );
  }

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}