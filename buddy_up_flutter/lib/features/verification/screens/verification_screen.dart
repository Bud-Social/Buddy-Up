import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../providers/verification_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _imagePicker = ImagePicker();
  final _docTypeCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _docTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadDocument() async {
    final docType = _docTypeCtrl.text.trim();
    if (docType.isEmpty) return;

    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);
      final formData = FormData.fromMap({
        'document_type': docType,
        'file': await MultipartFile.fromFile(file.path, filename: file.name),
      });
      await repo.uploadDocument(formData);
      await repo.createSubmission({'submission_type': docType});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document submitted for verification!')),
        );
        ref.invalidate(verificationSubmissionsProvider);
        _docTypeCtrl.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(verificationSubmissionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload a document to verify your identity.',
              style: TextStyle(color: BuddyColors.textSecondary)),
            const SizedBox(height: 16),
            BuddyInput(label: 'Document Type', controller: _docTypeCtrl,
              hint: 'e.g. passport, driver_license, national_id'),
            const SizedBox(height: 16),
            BuddyButton(
              label: 'Upload Document',
              fullWidth: true,
              isLoading: _isSubmitting,
              icon: Icons.upload_file,
              onPressed: _uploadDocument,
            ),
            const SizedBox(height: 32),
            const Text('Submission History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            submissionsAsync.when(
              data: (submissions) {
                if (submissions.isEmpty) {
                  return const EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'No submissions yet',
                  );
                }
                return Column(
                  children: submissions.map((s) => Card(
                    color: BuddyColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(_statusIcon(s.status), color: _statusColor(s.status)),
                      title: Text(s.submissionType.replaceAll('_', ' ')),
                      subtitle: Text(s.status, style: TextStyle(color: _statusColor(s.status))),
                      trailing: Text(_formatDate(s.submittedAt), style: const TextStyle(fontSize: 12, color: BuddyColors.textSecondary)),
                    ),
                  )).toList(),
                );
              },
              loading: () => const ShimmerList(itemCount: 3, itemHeight: 72),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.hourglass_empty;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved': return BuddyColors.green;
      case 'rejected': return BuddyColors.red;
      default: return Colors.orange;
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
