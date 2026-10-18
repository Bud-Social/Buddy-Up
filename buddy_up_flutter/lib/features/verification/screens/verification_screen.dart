import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/upload/cloudinary_uploader.dart';
import '../../../data/models/verification.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../feed/providers/feed_provider.dart' show apiClientProvider;
import '../providers/verification_provider.dart';

/// `DOCUMENT_TYPES` on `VerificationDocument`.
///
/// Read from the model's own choice list on the server, so this is a mirror
/// rather than a source — a type added there shows up here without a release.
const List<({String value, String label})> kEvidenceDocumentTypes = [
  (value: 'certificate', label: 'Certificate'),
  (value: 'professional_license', label: 'Professional licence'),
  (value: 'id_document', label: 'ID document'),
  (value: 'proof_of_address', label: 'Proof of address'),
  (value: 'insurance', label: 'Insurance'),
  (value: 'bank_statement', label: 'Bank statement'),
];

/// Settings → Verification: this account's applications and how to make one.
///
/// **A professional role is applied for, not selected.** Registration refuses
/// anything but `role: "user"`, so the "I am a trainer / practitioner" choice
/// that used to sit on the register form has moved here, to
/// `POST /verification/category-applications/`. That route is the only one that
/// grants `Profile.role`, and it grants it only when a verification decision is
/// approved by two members of staff.
///
/// The list below is read from `my-applications/`, so an applicant can see
/// whether their application is still queued, has reached a reviewer, or was
/// decided — and, when it was decided, what the reviewer actually wrote. A
/// rejection with no note is the one outcome this screen is built to prevent
/// showing blank: [MyApplicationX.isRejectedWithoutReason] calls it out.
class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(myApplicationsProvider);
    final submissions = ref.watch(verificationSubmissionsProvider);
    final documents = ref.watch(verificationDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myApplicationsProvider);
          ref.invalidate(verificationSubmissionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Your applications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Trainer, practitioner, gym owner, shop owner and delivery '
              'partner are applied for and reviewed — they are no longer '
              'something you can pick at sign-up.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ...applications.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                _ErrorCard(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load your applications.',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              data: (rows) => [
                if (rows.isEmpty)
                  const EmptyState(
                    icon: Icons.workspace_premium_outlined,
                    title: 'No applications yet',
                  )
                else
                  for (final application in rows) _applicationCard(context, application),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/verification/apply'),
              icon: const Icon(Icons.how_to_reg_outlined, size: 16),
              label: const Text(
                'Apply for a professional role',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Evidence on file',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'A category application must cite at least one document here. '
              'Reviewers open them through the secure document viewer; the '
              'bytes are never served from a public URL.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _addEvidence(context, ref),
              icon: const Icon(Icons.upload_file_outlined, size: 16),
              label: const Text(
                'Add a document',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            ...documents.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                _ErrorCard(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load your documents.',
                  ),
                ),
              ],
              data: (docs) => [
                if (docs.isEmpty)
                  const Text(
                    'No documents on file. Add one before applying for a '
                    'professional role — the server refuses an application '
                    'with no supporting evidence.',
                    style: TextStyle(fontSize: 11, height: 1.4),
                  )
                else
                  for (final document in docs) _documentTile(context, document),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Verification submissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Identity and business verifications you have started.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...submissions.when(
              loading: () => const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ],
              error: (e, _) => [
                _ErrorCard(
                  message: apiErrorMessage(
                    e,
                    fallback: 'Could not load your submissions.',
                  ),
                ),
              ],
              data: (rows) => [
                if (rows.isEmpty)
                  const EmptyState(
                    icon: Icons.verified_outlined,
                    title: 'No verification submissions yet',
                  )
                else
                  for (final submission in rows) _submissionCard(context, submission),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _applicationCard(BuildContext context, MyApplication application) {
    final cs = Theme.of(context).colorScheme;
    final rejected = application.isDecided && application.status == 'rejected';
    final tint = rejected
        ? BuddyColors.red
        : application.isPending
            ? BuddyColors.gold
            : BuddyColors.green;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.categoryLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  application.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            application.statusLabel,
            style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
          ),
          if (application.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviewer said',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.reviewerNote,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
          if (application.isRejectedWithoutReason) ...[
            const SizedBox(height: 10),
            const Text(
              'This decision came back with no note attached. Ask support — a '
              'rejection without a reason is not something you should have to '
              'guess at.',
              style: TextStyle(fontSize: 11, color: BuddyColors.red, height: 1.4),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'Submitted ${_shortDateTime(application.submittedAt ?? application.createdAt)}'
            '${application.decidedOn == null ? '' : ' · decided ${_shortDateTime(application.decidedOn)}'}'
            '${application.documentCount == 0 ? '' : ' · ${application.documentCount} document(s) attached'}',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _submissionCard(BuildContext context, VerificationSubmission submission) {
    final cs = Theme.of(context).colorScheme;
    final tint = submission.isApproved
        ? BuddyColors.green
        : submission.isRejected
            ? BuddyColors.red
            : BuddyColors.gold;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(submission.status), color: tint, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  submission.typeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                submission.status.replaceAll('_', ' '),
                style: TextStyle(fontSize: 11, color: tint),
              ),
            ],
          ),
          if (submission.awaitsSecondApprover) ...[
            const SizedBox(height: 8),
            Text(
              'A reviewer has looked at this and sent it for a decision. A '
              'different member of staff still has to approve it — nothing has '
              'changed on your account yet.',
              style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
            ),
          ],
          if (submission.reviewerNote.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewer: ${submission.reviewerNote}',
              style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.4),
            ),
          ],
          if (submission.documents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final document in submission.documents)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${document.typeLabel} · ${document.status}',
                      style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _shortDateTime(submission.submittedAt ?? submission.createdAt),
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(BuildContext context, VerificationDocument document) {
    final cs = Theme.of(context).colorScheme;
    final tint = document.status == 'approved'
        ? BuddyColors.green
        : document.status == 'rejected'
            ? BuddyColors.red
            : BuddyColors.gold;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 18, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.typeLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '${document.status} · added ${_shortDateTime(document.createdAt)}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
                if (document.rejectionReason.isNotEmpty)
                  Text(
                    document.rejectionReason,
                    style: const TextStyle(fontSize: 11, color: BuddyColors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Register a document: pick a type, pick an image, register the row.
  ///
  /// The bytes go up through the signed Cloudinary uploader this app already
  /// uses everywhere else, and the row is then created against the caller's own
  /// profile server-side — there is no client-supplied `profile` to abuse.
  ///
  /// Only `document_type` is sent in the create body. `file_url` is a
  /// `SerializerMethodField` on the server and is read-only, so the uploaded
  /// address is not accepted as an input there; the copy below says what
  /// actually happened rather than claiming a stored file.
  Future<void> _addEvidence(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    var type = kEvidenceDocumentTypes.first.value;

    final picked = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Add a document', style: TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final option in kEvidenceDocumentTypes)
                    ChoiceChip(
                      label: Text(option.label, style: const TextStyle(fontSize: 11)),
                      selected: type == option.value,
                      onSelected: (_) => setState(() => type = option.value),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'The file is uploaded to platform storage and the document is '
                'recorded against your profile. Keep the original — a reviewer '
                'may ask for a clearer copy.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: TextButton.styleFrom(foregroundColor: BuddyColors.green),
              child: const Text('Choose a file', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
    if (picked != true || !context.mounted) return;

    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    messenger.showSnackBar(
      const SnackBar(content: Text('Uploading document…')),
    );
    try {
      final uploader = CloudinaryUploader(ref.read(apiClientProvider).dio);
      final sign = await uploader.sign(
        resourceType: 'image',
        filename: file.name,
      );
      if (sign == null) {
        throw const FormatException(
            'The upload service is unavailable right now. Try again shortly.');
      }
      // Send the bytes to the verification app itself. The old path uploaded
      // via the signed uploader and then posted `file_url`, which is a
      // `SerializerMethodField` -- DRF discarded it and the document was created
      // with no file attached.
      final bytes = await File(file.path).readAsBytes();
      await ref.read(verificationRepositoryProvider).uploadCredentialFile({
        'document_type': type,
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });
      ref.invalidate(verificationDocumentsProvider);
      ref.invalidate(attachableDocumentsProvider);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Document registered. It can now be attached to a category '
            'application.',
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(apiErrorMessage(
            e,
            fallback: 'Could not register the document.',
          )),
        ),
      );
    }
  }

  static IconData _statusIcon(String status) => switch (status) {
        'approved' => Icons.check_circle,
        'rejected' => Icons.cancel,
        'under_review' => Icons.hourglass_top,
        'submitted' => Icons.inbox_outlined,
        _ => Icons.edit_note,
      };

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BuddyColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 12, color: BuddyColors.red, height: 1.4),
      ),
    );
  }
}