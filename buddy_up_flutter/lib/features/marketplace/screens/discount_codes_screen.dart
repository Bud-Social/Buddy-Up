import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/marketplace_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../shared/widgets/page_loader.dart';

class DiscountCodesScreen extends ConsumerStatefulWidget {
  const DiscountCodesScreen({super.key});

  @override
  ConsumerState<DiscountCodesScreen> createState() => _DiscountCodesScreenState();
}

class _DiscountCodesScreenState extends ConsumerState<DiscountCodesScreen> {
  DiscountCode? _editing;
  bool _saving = false;
  bool _showForm = false;

  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _campaignCtrl = TextEditingController();
  final _pctCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();
  final _maxPerUserCtrl = TextEditingController();
  final _artifactsCtrl = TextEditingController();
  final _minPurchaseCtrl = TextEditingController();
  String _discountType = 'percentage';
  String _codeType = 'text';
  String _validFrom = '';
  String _validUntil = '';
  bool _isActive = true;

  DiscountAnalytics? _analytics;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _campaignCtrl.dispose();
    _pctCtrl.dispose();
    _usageLimitCtrl.dispose();
    _maxPerUserCtrl.dispose();
    _artifactsCtrl.dispose();
    _minPurchaseCtrl.dispose();
    super.dispose();
  }

  void _resetForm() {
    _codeCtrl.clear();
    _descCtrl.clear();
    _campaignCtrl.clear();
    _pctCtrl.text = '0';
    _usageLimitCtrl.text = '0';
    _maxPerUserCtrl.text = '0';
    _artifactsCtrl.text = '{}';
    _minPurchaseCtrl.text = '{}';
    _discountType = 'percentage';
    _codeType = 'text';
    _validFrom = '';
    _validUntil = '';
    _isActive = true;
    _editing = null;
  }

  void _editCode(DiscountCode code) {
    _editing = code;
    _codeCtrl.text = code.code;
    _descCtrl.text = code.description;
    _campaignCtrl.text = code.campaign;
    _pctCtrl.text = code.discountPct.toString();
    _usageLimitCtrl.text = code.usageLimit.toString();
    _maxPerUserCtrl.text = code.maxUsesPerUser.toString();
    _artifactsCtrl.text = code.discountArtifacts.toString();
    _minPurchaseCtrl.text = code.minPurchaseArtifacts.toString();
    _discountType = code.discountType;
    _codeType = code.codeType;
    _validFrom = code.validFrom ?? '';
    _validUntil = code.validUntil ?? '';
    _isActive = code.isActive;
    _showForm = true;
    setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final repo = ref.read(marketplaceRepositoryProvider);
      final payload = <String, dynamic>{
        'code': _codeCtrl.text,
        'discount_type': _discountType,
        'code_type': _codeType,
        'discount_pct': int.tryParse(_pctCtrl.text) ?? 0,
        'description': _descCtrl.text,
        'campaign': _campaignCtrl.text,
        'usage_limit': int.tryParse(_usageLimitCtrl.text) ?? 0,
        'max_uses_per_user': int.tryParse(_maxPerUserCtrl.text) ?? 0,
        'is_active': _isActive,
        'valid_from': _validFrom.isEmpty ? null : _validFrom,
        'valid_until': _validUntil.isEmpty ? null : _validUntil,
      };
      if (_discountType == 'fixed_artifacts') {
        try {
          final parsed = jsonDecode(_artifactsCtrl.text);
          payload['discount_artifacts'] = Map<String, dynamic>.from(parsed as Map);
        } catch (_) {
          payload['discount_artifacts'] = <String, dynamic>{};
        }
      }
      if (_minPurchaseCtrl.text.isNotEmpty && _minPurchaseCtrl.text != '{}') {
        try {
          final parsed = jsonDecode(_minPurchaseCtrl.text);
          payload['min_purchase_artifacts'] = Map<String, dynamic>.from(parsed as Map);
        } catch (_) {
          payload['min_purchase_artifacts'] = <String, dynamic>{};
        }
      }
      if (_editing != null) {
        await repo.updateDiscountCode(_editing!.id, payload);
      } else {
        await repo.createDiscountCode(payload);
      }
      _resetForm();
      _showForm = false;
      ref.invalidate(discountCodesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _toggleActive(DiscountCode code) async {
    try {
      await ref.read(marketplaceRepositoryProvider).patchDiscountCode(code.id, {
        'action': code.isActive ? 'suspend' : 'reactivate',
      });
      ref.invalidate(discountCodesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(code.isActive ? 'Code suspended.' : 'Code reactivated.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Retire Code'),
      content: const Text('This code will no longer be usable. Continue?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Retire')),
      ],
    ));
    if (confirm != true) return;
    try {
      await ref.read(marketplaceRepositoryProvider).deleteDiscountCode(id);
      ref.invalidate(discountCodesProvider);
    } catch (_) {}
  }

  Future<void> _share(DiscountCode code) async {
    try {
      final raw = await ref.read(marketplaceRepositoryProvider).shareDiscountCode(code.id);
      final result = DiscountShareResult.fromJson(raw['data'] as Map<String, dynamic>);
      if (!mounted) return;
      if (result.qrCode != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code shared (save from gallery)')),
        );
      }
      await Clipboard.setData(ClipboardData(text: result.code));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code "${result.code}" copied to clipboard')),
        );
      }
      ref.invalidate(discountCodesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  Future<void> _loadAnalytics(String id) async {
    try {
      final raw = await ref.read(marketplaceRepositoryProvider).getDiscountCodeAnalytics(id);
      setState(() => _analytics = DiscountAnalytics.fromJson(raw['data'] as Map<String, dynamic>));
    } catch (_) {}
  }

  Future<void> _pickValidFrom() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (dt == null || !mounted) return;
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (tm != null) {
      setState(() => _validFrom = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute).toIso8601String());
    }
  }

  Future<void> _pickValidUntil() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (dt == null || !mounted) return;
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (tm != null) {
      setState(() => _validUntil = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute).toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(discountCodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Codes'),
        actions: [
          TextButton.icon(
            onPressed: () {
              _resetForm();
              setState(() => _showForm = !_showForm);
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          if (_analytics != null) _buildAnalytics(),
          Expanded(
            child: codesAsync.when(
              data: (codes) => codes.isEmpty
                ? const Center(child: Text('No discount codes yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: codes.length,
                    itemBuilder: (_, i) => _codeCard(codes[i]),
                  ),
              loading: () => const PageLoader(),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: BuddyColors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editing != null ? 'Edit Code' : 'New Code', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: _codeCtrl, decoration: const InputDecoration(labelText: 'Code *', hintText: 'SUMMER20'), textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _discountType,
                    decoration: const InputDecoration(labelText: 'Discount Type'),
                    items: const [DropdownMenuItem(value: 'percentage', child: Text('Percentage')), DropdownMenuItem(value: 'fixed_artifacts', child: Text('Fixed Artifacts'))],
                    onChanged: (v) => setState(() => _discountType = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _codeType,
                    decoration: const InputDecoration(labelText: 'Code Type'),
                    items: const [DropdownMenuItem(value: 'text', child: Text('Text')), DropdownMenuItem(value: 'qr', child: Text('QR Code'))],
                    onChanged: (v) => setState(() => _codeType = v!),
                  ),
                ),
              ],
            ),
            if (_discountType == 'percentage') ...[
              const SizedBox(height: 8),
              TextField(controller: _pctCtrl, decoration: const InputDecoration(labelText: 'Discount %'), keyboardType: TextInputType.number),
            ],
            if (_discountType == 'fixed_artifacts') ...[
              const SizedBox(height: 8),
              TextField(controller: _artifactsCtrl, decoration: const InputDecoration(labelText: 'Artifacts JSON'), maxLines: 2),
            ],
            const SizedBox(height: 8),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
            const SizedBox(height: 8),
            TextField(controller: _campaignCtrl, decoration: const InputDecoration(labelText: 'Campaign')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Valid From'),
                    readOnly: true,
                    controller: TextEditingController(text: _validFrom),
                    onTap: _pickValidFrom,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Valid Until'),
                    readOnly: true,
                    controller: TextEditingController(text: _validUntil),
                    onTap: _pickValidUntil,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _usageLimitCtrl, decoration: const InputDecoration(labelText: 'Usage Limit'), keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _maxPerUserCtrl, decoration: const InputDecoration(labelText: 'Max/User'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving...' : (_editing != null ? 'Update' : 'Create')),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: () => setState(() { _showForm = false; _resetForm(); }), child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalytics() {
    final a = _analytics!;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: BuddyColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Analytics: ${a.code.code}', style: const TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => setState(() => _analytics = null), child: const Text('Close')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _stat('Uses', a.totalUses.toString()),
              _stat('Successful', a.successfulUses.toString()),
              _stat('Savings', '\$${a.totalSavingsUsd.toStringAsFixed(2)}'),
              _stat('Shares', a.shareCount.toString()),
              _stat('Unique Users', a.uniqueUsers.toString()),
              _stat('Returning', a.returningUsers.toString()),
              _stat('Retention', '${a.retentionRate.toStringAsFixed(0)}%'),
              _stat('Avg Savings', '\$${a.avgSavingsPerUser.toStringAsFixed(2)}'),
              _stat('Order Value', '\$${a.totalOrderValueUsd.toStringAsFixed(2)}'),
            ],
          ),
          if (a.repeatUsageDistribution.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Repeat Usage', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
            const SizedBox(height: 4),
            ...a.repeatUsageDistribution.map((row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                '${row['uses'] ?? 0}× used: ${row['users'] ?? 0} users',
                style: const TextStyle(fontSize: 11),
              ),
            )),
          ],
          if (a.topUsers.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Top Users', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
            const SizedBox(height: 4),
            ...a.topUsers.map((row) {
              final display = row['user__display_name'] ?? row['user__username'] ?? 'user';
              final saved = num.tryParse('${row['savings'] ?? 0}')?.toDouble() ?? 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  '$display: ${row['uses'] ?? 0} uses · \$${saved.toStringAsFixed(2)} saved',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: BuddyColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _codeCard(DiscountCode code) {
    final isExpired = code.isExpired;
    return Card(
      color: BuddyColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(code.code, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14)),
                const SizedBox(width: 8),
                if (isExpired)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: BuddyColors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: const Text('Expired', style: TextStyle(fontSize: 10, color: BuddyColors.red)))
                else if (!code.isActive)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: const Text('Inactive', style: TextStyle(fontSize: 10, color: Colors.orange)))
                else
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: BuddyColors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: const Text('Active', style: TextStyle(fontSize: 10, color: BuddyColors.green))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              code.discountType == 'percentage' ? '${code.discountPct}% off' : 'Fixed artifact discount',
              style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary),
            ),
            if (code.description.isNotEmpty) Text(code.description, style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
              Row(
                children: [
                  Text('${code.timesUsed}/${code.usageLimit == 0 ? '∞' : code.usageLimit.toString()} uses', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary.withValues(alpha: 0.7))),
                  const SizedBox(width: 12),
                  Text('${code.shareCount} shares', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary.withValues(alpha: 0.7))),
                  if (code.validUntil != null) ...[
                    const SizedBox(width: 12),
                    Text('Expires ${code.validUntil}', style: TextStyle(fontSize: 11, color: BuddyColors.textSecondary.withValues(alpha: 0.7))),
                  ],
                ],
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(code.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      size: 18, color: code.isActive ? Colors.orange : BuddyColors.green),
                  tooltip: code.isActive ? 'Suspend' : 'Reactivate',
                  onPressed: () => _toggleActive(code),
                ),
                IconButton(icon: const Icon(Icons.analytics, size: 18), onPressed: () => _loadAnalytics(code.id)),
                IconButton(icon: const Icon(Icons.share, size: 18), onPressed: () => _share(code)),
                IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editCode(code)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _delete(code.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
