import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../feed/providers/feed_provider.dart' show apiClientProvider;
import '../../../shared/widgets/button.dart';
import '../widgets/info_blocks.dart';

const _topics = <(String, String)>[
  ('general', 'General'),
  ('support', 'Support'),
  ('gyms', 'Gyms & Partnerships'),
  ('trainers', 'Trainers'),
  ('press', 'Press'),
];

const _faq = <(String, String)>[
  (
    'How fast do you reply?',
    'Within two business days. Partnership and press inquiries usually get a same-week response.',
  ),
  (
    'Support or partnership?',
    'Account and app help goes through this form with the Support topic. Brands, gyms, and sponsors: choose Gyms & Partnerships so the right team picks it up.',
  ),
  (
    'Something unsafe on the platform?',
    'Use the in-app Report button for the fastest response, or email report@buddyup.co.ke. Emergencies: contact local emergency services first.',
  ),
];

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _topic = 'general';
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    if (auth.profile != null) {
      _name.text = auth.profile!.displayName;
    }
    if (auth.user?.email.isNotEmpty ?? false) {
      _email.text = auth.user!.email;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<Map<String, dynamic>>(
            '/waitlist/contact/',
            data: {
              'name': _name.text.trim(),
              'email': _email.text.trim(),
              'topic': _topic,
              'subject': _subject.text.trim(),
              'message': _message.text.trim(),
            },
          );
      if (mounted) setState(() => _sent = true);
    } on DioException catch (e) {
      final body = e.response?.data;
      String message = 'Something went wrong. Please try again.';
      if (body is Map) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            message = '${first.first}';
          } else if (first != null) {
            message = '$first';
          }
        } else if (body['message'] is String) {
          message = body['message'] as String;
        }
      }
      if (mounted) setState(() => _error = message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _mail(String address) async {
    await launchUrl(
      Uri.parse('mailto:$address'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      title: 'Talk to a human.',
      leadingIcon: LucideIcons.messageCircle,
      subtitle:
          'Real humans, Nairobi time. Partnerships, gym onboarding, press, or support — one inbox, routed to the right team.',
      children: [
        if (_sent)
          InfoCard(
            child: Column(
              children: [
                const Icon(
                  LucideIcons.checkCircle2,
                  size: 40,
                  color: BuddyColors.green,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Message received',
                  style: TextStyle(
                    color: BuddyColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We reply within two business days. For urgent safety issues email report@buddyup.co.ke.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BuddyColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                BuddyButton(
                  label: 'Send another message',
                  variant: BuddyButtonVariant.outline,
                  fullWidth: true,
                  onPressed: () => setState(() {
                    _sent = false;
                    _subject.clear();
                    _message.clear();
                  }),
                ),
              ],
            ),
          )
        else
          InfoCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Send us a message',
                    style: TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InfoTextField(
                    label: 'Your name',
                    controller: _name,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Tell us your name' : null,
                  ),
                  InfoTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'Add your email';
                      if (!RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  InfoDropdown(
                    label: 'Topic',
                    value: _topic,
                    options: _topics,
                    onChanged: (v) => setState(() => _topic = v),
                  ),
                  InfoTextField(
                    label: 'Subject (optional)',
                    controller: _subject,
                  ),
                  InfoTextField(
                    label: 'Message',
                    controller: _message,
                    maxLines: 5,
                    hint: 'How can we help?',
                    validator: (v) => (v ?? '').trim().length < 5
                        ? 'Add a little more detail'
                        : null,
                  ),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: BuddyColors.red,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  BuddyButton(
                    label: _sending ? 'Sending…' : 'Send message',
                    fullWidth: true,
                    isLoading: _sending,
                    onPressed: _sending ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.mail, size: 18, color: BuddyColors.green),
                  SizedBox(width: 8),
                  Text(
                    'Prefer email?',
                    style: TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              InfoLink(
                'support@buddyupfit.com',
                icon: LucideIcons.arrowRight,
                onTap: () => _mail('support@buddyupfit.com'),
              ),
              const Text(
                'For safety issues use the in-app Report button or report@buddyup.co.ke.',
                style: TextStyle(
                  color: BuddyColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        for (final item in _faq)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      color: BuddyColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        InfoLink(
          'Looking for help using the app? Visit the Help Centre',
          onTap: () => context.push('/help'),
        ),
      ],
    );
  }
}
