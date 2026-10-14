import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verification.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/input.dart' show BuddyInput;
import '../providers/verification_provider.dart';

/// `POST /api/v1/verification/category-applications/` — apply for an elevated
/// role.
///
/// **This is where the "I am a trainer / practitioner" choice moved to.**
/// `RegisterSerializer.validate_role` now refuses anything but `"user"` and
/// points at this path, because a professional role used to be self-declared at
/// sign-up: `POST /auth/register/ {"role": "trainer"}` produced a trainer, and
/// `IsVerifiedTrainer` — which checks the role and nothing else — then treated
/// them as one.
///
/// **Two people still decide.** This POST only *files* the application. It
/// stamps `status='submitted'` and puts it in front of a reviewer, and a
/// reviewer filing a decision only queues it — `Profile.role` is written when a
/// second member of staff approves. The form says so on the button rather than
/// leaving the applicant to assume they are a trainer on the way out.
///
/// **Incomplete applications are refused at the door.** The server checks
/// [kCategoryRequiredFields] per category and rejects with a per-field 400; this
/// form applies the same rules locally so an applicant missing their credential
/// number finds out before a reviewer spends time on it. Supporting evidence is
/// mandatory for every category — a credential number with no document behind
/// it is not reviewable.
class CategoryApplicationScreen extends ConsumerStatefulWidget {
  const CategoryApplicationScreen({super.key});

  @override
  ConsumerState<CategoryApplicationScreen> createState() =>
      _CategoryApplicationScreenState();
}

class _CategoryApplicationScreenState
    extends ConsumerState<CategoryApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _credentialTitle = TextEditingController();
  final _credentialIssuer = TextEditingController();
  final _credentialId = TextEditingController();
  final _gymHandle = TextEditingController();
  final _notes = TextEditingController();

  String _category = 'trainer';
  String _scope = '';
  DateTime? _issuedDate;
  final Set<String> _selectedDocumentIds = {};
  bool _busy = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _credentialTitle.dispose();
    _credentialIssuer.dispose();
    _credentialId.dispose();
    _gymHandle.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// The credential fields this category must carry, per
  /// `REQUIRED_FIELDS_BY_TYPE`.
  List<String> get _required =>
      kCategoryRequiredFields[_category] ?? const <String>[];

  bool get _requiresGym => kCategoryRequiresGym.contains(_category);

  bool get _hasDocuments => _selectedDocumentIds.isNotEmpty;

  /// Client-side gate mirroring `CategoryApplicationSerializer.validate`.
  ///
  /// Returns null when the application is complete enough to send, and the
  /// blocking sentence otherwise.
  String? get _blocking {
    if (_required.contains('credential_title') &&
        _credentialTitle.text.trim().isEmpty) {
      return 'A credential title is required to apply for $_category.';
    }
    if (_required.contains('credential_issuer') &&
        _credentialIssuer.text.trim().isEmpty) {
      return 'A credential issuer is required to apply for $_category.';
    }
    if (_required.contains('credential_id') &&
        _credentialId.text.trim().isEmpty) {
      return 'A credential number is required to apply for $_category.';
    }
    if (_required.contains('issued_date') && _issuedDate == null) {
      return 'The date the credential was issued is required to apply for '
          '$_category.';
    }
    if (_required.contains('scope_of_practice') && _scope.isEmpty) {
      return 'A scope of practice is required to apply for $_category.';
    }
    if (_requiresGym && _gymHandle.text.trim().isEmpty) {
      return 'Name the gym you are applying to run — required for gym owner.';
    }
    if (!_hasDocuments) {
      return 'Supporting evidence is required for every category. Upload the '
          'document first, then select it below.';
    }
    return null;
  }

  Future<void> _pickIssuedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 1),
      firstDate: DateTime(now.year - 40),
      lastDate: now,
    );
    if (picked != null) setState(() => _issuedDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final blocked = _blocking;
    if (blocked != null) {
      setState(() => _error = blocked);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(verificationRepositoryProvider).createCategoryApplication({
        'category': _category,
        if (_credentialTitle.text.trim().isNotEmpty)
          'credential_title': _credentialTitle.text.trim(),
        if (_credentialIssuer.text.trim().isNotEmpty)
          'credential_issuer': _credentialIssuer.text.trim(),
        if (_credentialId.text.trim().isNotEmpty)
          'credential_id': _credentialId.text.trim(),
        if (_issuedDate != null) 'issued_date': _isoDate(_issuedDate!),
        if (_scope.isNotEmpty) 'scope_of_practice': _scope,
        if (_gymHandle.text.trim().isNotEmpty)
          'gym_handle': _gymHandle.text.trim(),
        'document_ids': _selectedDocumentIds.toList(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      ref.invalidate(myApplicationsProvider);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _notice = 'Application filed. It is now in front of a reviewer, and a '
            'second member of staff has to approve it before anything changes '
            'on your account. Track it under My applications.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = apiErrorMessage(
          e,
          fallback: 'Could not file the application.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(attachableDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply for a role')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _Intro(),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final choice in kCategoryApplicationChoices)
                  ChoiceChip(
                    label: Text(
                      choice.label,
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _category == choice.value,
                    onSelected: (_) => setState(() {
                      _category = choice.value;
                      _error = null;
                    }),
                    selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: _category == choice.value
                          ? BuddyColors.green
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            BuddyInput(
              controller: _credentialTitle,
              label: 'Credential title',
              hint: 'e.g. NASM Personal Trainer, Registered Physiotherapist',
              validator: _required.contains('credential_title')
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null,
            ),
            const SizedBox(height: 14),
            BuddyInput(
              controller: _credentialIssuer,
              label: 'Credential issuer',
              hint: 'e.g. National Academy of Sports Medicine',
              validator: _required.contains('credential_issuer')
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null,
            ),
            const SizedBox(height: 14),
            BuddyInput(
              controller: _credentialId,
              label: 'Credential number',
              hint: 'The number printed on the certificate',
              validator: _required.contains('credential_id')
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                  : null,
            ),
            const SizedBox(height: 14),
            if (_required.contains('issued_date')) ...[
              const BuddyInput(
                label: 'Issued on',
                hint: 'Tap the field below to pick a date',
                enabled: false,
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: _pickIssuedDate,
                icon: const Icon(Icons.event_outlined, size: 16),
                label: Text(
                  _issuedDate == null ? 'Pick the issue date' : _isoDate(_issuedDate!),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (_required.contains('scope_of_practice')) ...[
              Text(
                'Scope of practice',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final choice in kScopeOfPracticeChoices)
                    ChoiceChip(
                      label: Text(choice.label, style: const TextStyle(fontSize: 11)),
                      selected: _scope == choice.value,
                      onSelected: (_) => setState(() => _scope = choice.value),
                      selectedColor: BuddyColors.green.withValues(alpha: 0.2),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            if (_requiresGym) ...[
              BuddyInput(
                controller: _gymHandle,
                label: 'Gym handle',
                hint: 'The gym you are applying to run',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required for gym owner' : null,
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Supporting evidence',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select the credential document you already uploaded. The server '
              're-checks that each id belongs to you.',
              style: TextStyle(fontSize: 11, height: 1.35),
            ),
            const SizedBox(height: 8),
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
                Text(
                  apiErrorMessage(e, fallback: 'Could not load your documents.'),
                  style: const TextStyle(fontSize: 11, color: BuddyColors.red),
                ),
              ],
              data: (docs) => [
                if (docs.isEmpty)
                  const Text(
                    'You have no undecided documents on file. Upload one on '
                    'the Verification screen first — an application without '
                    'evidence is refused by the server.',
                    style: TextStyle(fontSize: 11, height: 1.4),
                  )
                else
                  for (final document in docs)
                    CheckboxListTile(
                      value: _selectedDocumentIds.contains(document.id),
                      onChanged: (value) => setState(() {
                        if (value ?? false) {
                          _selectedDocumentIds.add(document.id);
                        } else {
                          _selectedDocumentIds.remove(document.id);
                        }
                      }),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        document.typeLabel,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        '${document.status} · uploaded ${_shortDateTime(document.createdAt)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 10),
            BuddyInput(
              controller: _notes,
              label: 'Anything else the reviewer should know (optional)',
              hint: 'Experience, specialisms, coverage…',
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              _Banner(
                message: _error!,
                colour: BuddyColors.red,
              ),
              const SizedBox(height: 12),
            ],
            if (_notice != null) ...[
              _Banner(
                message: _notice!,
                colour: BuddyColors.green,
              ),
              const SizedBox(height: 12),
            ],
            const _TwoPersonNote(),
            const SizedBox(height: 12),
            BuddyButton(
              label: 'File application',
              fullWidth: true,
              isLoading: _busy,
              onPressed: _busy ? null : _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _shortDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    return iso.replaceFirst('T', ' ').split('.').first.split('+').first;
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BuddyColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuddyColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: BuddyColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Roles are granted by review, not chosen at sign-up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Registration no longer accepts an elevated role, so this form is '
            'the only route to trainer, practitioner, gym owner, shop owner or '
            'delivery partner. Filing an application does not make you one.',
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// The two-person rule, stated on the form rather than discovered afterwards.
class _TwoPersonNote extends StatelessWidget {
  const _TwoPersonNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.group_outlined, size: 15, color: BuddyColors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'A decision needs two people. One member of staff reviews and '
              'sends it for a decision; a different member of staff approves or '
              'rejects. Neither can be you, and neither can be the same person '
              'as the other.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color colour;

  const _Banner({required this.message, required this.colour});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colour.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 12, color: colour, height: 1.45),
      ),
    );
  }
}