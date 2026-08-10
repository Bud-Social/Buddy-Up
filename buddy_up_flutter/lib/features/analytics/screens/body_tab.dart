import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/analytics.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/analytics_provider.dart';
import '../utils/analytics_format.dart';
import '../widgets/analytics_widgets.dart';

class BodyTab extends ConsumerStatefulWidget {
  final BodySummary? summary;

  const BodyTab({super.key, this.summary});

  @override
  ConsumerState<BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends ConsumerState<BodyTab> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;
  XFile? _scalePhoto;
  bool _isSubmitting = false;
  bool _isReadingScale = false;

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photo = picked);
    }
  }

  Future<void> _pickScalePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _scalePhoto = picked;
        _isReadingScale = true;
      });
      await _readWeightFromScale(picked);
    }
  }

  Future<void> _readWeightFromScale(XFile file) async {
    final data = <String, dynamic>{
      'scale_photo': MultipartFile.fromFileSync(file.path, filename: file.name),
    };
    final reading = await ref
        .read(analyticsLogProvider.notifier)
        .readBodyWeight(data);
    if (!mounted) return;
    setState(() => _isReadingScale = false);
    final weight = reading?['weight_kg'];
    if (weight is num && weight > 0) {
      _weightController.text = weight.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Weight ${weight.toStringAsFixed(1)} kg read from scale snap.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not read the scale display — enter your weight manually.',
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final data = <String, dynamic>{
      'weight_kg': double.tryParse(_weightController.text) ?? 0,
    };
    final bodyFat = double.tryParse(_bodyFatController.text);
    if (bodyFat != null) data['body_fat_pct'] = bodyFat;

    if (_photo != null) {
      data['photo'] = MultipartFile.fromFileSync(
        _photo!.path,
        filename: _photo!.name,
      );
    }
    if (_scalePhoto != null) {
      data['scale_photo'] = MultipartFile.fromFileSync(
        _scalePhoto!.path,
        filename: _scalePhoto!.name,
      );
    }

    final created = await ref
        .read(analyticsLogProvider.notifier)
        .logBodyMetric(data);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    if (created != null) {
      _formKey.currentState!.reset();
      _weightController.clear();
      _bodyFatController.clear();
      setState(() {
        _photo = null;
        _scalePhoto = null;
      });
      await ref.read(analyticsSummaryProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not log weight. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    if (s == null) {
      return const EmptyState(
        icon: Icons.monitor_weight_outlined,
        title: 'No body data',
      );
    }

    final change = s.weightChangeKg;
    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsSummaryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              StatCard(
                label: 'Check-ins',
                value: '${s.count}',
                icon: Icons.edit_calendar,
              ),
              StatCard(
                label: 'Current',
                value: s.latestWeightKg != null
                    ? '${formatNumber(s.latestWeightKg!, decimals: 1)} kg'
                    : '—',
                icon: Icons.monitor_weight_outlined,
              ),
              StatCard(
                label: 'Change',
                value: change != null
                    ? '${change >= 0 ? '+' : ''}${formatNumber(change, decimals: 1)} kg'
                    : '—',
                icon: change != null && change < 0
                    ? Icons.trending_down
                    : Icons.trending_up,
                accent: change != null && change < 0
                    ? BuddyColors.green
                    : BuddyColors.gold,
              ),
            ],
          ),
          if (s.latestBodyFatPct != null) ...[
            const SizedBox(height: 12),
            StatCard(
              label: 'Body Fat',
              value: '${formatNumber(s.latestBodyFatPct!, decimals: 1)}%',
              icon: Icons.percent,
            ),
          ],
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Log Check-in',
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildLogForm(),
          if (s.series.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'Weight Trend', icon: Icons.show_chart),
            const SizedBox(height: 8),
            _buildTrend(s.series),
          ],
          if (s.series.length > 1) ...[
            const SizedBox(height: 16),
            const SectionHeader(
              title: 'Progress Snaps',
              icon: Icons.photo_library_outlined,
            ),
            const SizedBox(height: 8),
            _buildSnaps(s.series),
          ],
        ],
      ),
    );
  }

  Widget _buildLogForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _bodyFatController,
                    style: const TextStyle(color: BuddyColors.textPrimary),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Body fat %'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPhotoSlot(
                    title: 'Body snap',
                    file: _photo,
                    onTap: _pickPhoto,
                    onClear: _photo != null
                        ? () => setState(() => _photo = null)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildScaleSlot()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Saving…' : 'Log Weight'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSlot({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    if (file != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(file.path),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 140,
                color: BuddyColors.surfaceRaised,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: BuddyColors.textSecondary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          if (onClear != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onClear,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: BuddyColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BuddyColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo,
              color: BuddyColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: BuddyColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleSlot() {
    if (_scalePhoto != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_scalePhoto!.path),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 140,
                color: BuddyColors.surfaceRaised,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: BuddyColors.textSecondary,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _scalePhoto = null),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          if (_isReadingScale)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: BuddyColors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Reading scale…',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return GestureDetector(
      onTap: _isReadingScale ? null : _pickScalePhoto,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: BuddyColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BuddyColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.scale, color: BuddyColors.textSecondary, size: 28),
            SizedBox(height: 6),
            Text(
              'Scale snap\n(auto-reads weight)',
              textAlign: TextAlign.center,
              style: TextStyle(color: BuddyColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrend(List<BodySeriesPoint> series) {
    final weights = series.map((p) => p.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW) == 0 ? 1.0 : (maxW - minW);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BuddyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                minW.toStringAsFixed(1),
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                maxW.toStringAsFixed(1),
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _WeightLinePainter(
                weights: weights,
                min: minW,
                range: range,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                formatDate(series.first.measuredAt, includeTime: false),
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                formatDate(series.last.measuredAt, includeTime: false),
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnaps(List<BodySeriesPoint> series) {
    final snaps = series.reversed.toList();
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: snaps.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final p = snaps[index];
          return Column(
            children: [
              SizedBox(
                height: 90,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: p.photoUrl.isEmpty
                          ? Container(
                              width: 60,
                              height: 90,
                              color: BuddyColors.surfaceRaised,
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: BuddyColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            )
                          : Image.network(
                              p.photoUrl,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 60,
                                height: 90,
                                color: BuddyColors.surfaceRaised,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: BuddyColors.textSecondary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: p.scalePhotoUrl.isEmpty
                          ? Container(
                              width: 60,
                              height: 90,
                              color: BuddyColors.surfaceRaised,
                              child: const Center(
                                child: Icon(
                                  Icons.scale,
                                  color: BuddyColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            )
                          : Image.network(
                              p.scalePhotoUrl,
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 60,
                                height: 90,
                                color: BuddyColors.surfaceRaised,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: BuddyColors.textSecondary,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${p.weightKg.toStringAsFixed(1)}kg',
                style: const TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeightLinePainter extends CustomPainter {
  final List<double> weights;
  final double min;
  final double range;

  _WeightLinePainter({
    required this.weights,
    required this.min,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;
    final paint = Paint()
      ..color = BuddyColors.green
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    for (var i = 0; i < weights.length; i++) {
      final x = size.width * i / (weights.length - 1);
      final y = size.height - ((weights[i] - min) / range) * size.height;
      points.add(Offset(x, y));
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(line, paint);

    final dotPaint = Paint()
      ..color = BuddyColors.green
      ..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_WeightLinePainter oldDelegate) =>
      oldDelegate.weights != weights ||
      oldDelegate.min != min ||
      oldDelegate.range != range;
}
