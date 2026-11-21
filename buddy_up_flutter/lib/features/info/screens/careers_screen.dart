import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../feed/providers/feed_provider.dart' show apiClientProvider;
import '../../../shared/widgets/button.dart';
import '../widgets/info_blocks.dart';

class _Role {
  final String title;
  final String location;
  final String type;
  final String description;
  final List<String> points;

  const _Role(
    this.title,
    this.location,
    this.type,
    this.description,
    this.points,
  );
}

const _roles = <_Role>[
  _Role(
    'Founding Mobile Engineer',
    'Nairobi · Hybrid',
    'Full-time',
    'Own the BuddyUp Fit mobile experience end to end — ship the PWA and native apps our community trains with daily.',
    [
      'React Native / Flutter shipped to stores',
      'Offline-first thinking',
      'Product-minded, fast loops',
    ],
  ),
  _Role(
    'Backend Engineer (Django)',
    'Nairobi · Hybrid',
    'Full-time',
    'Scale the APIs behind gyms, lives, bookings, and wallets — reliability first, millions of check-ins later.',
    [
      'Django + Postgres in production',
      'Celery, WebSockets, payments',
      'You write the tests you ship',
    ],
  ),
  _Role(
    'Community & Gym Partnerships Lead',
    'Nairobi · On the ground',
    'Full-time',
    'Sign the gyms, onboard the coaches, and grow the fitness family across Kenya — our most human role.',
    [
      'Deep Nairobi fitness network',
      'Partner onboarding & success',
      'Events and launch activations',
    ],
  ),
  _Role(
    'Content & Social Lead',
    'Remote · Kenya hours',
    'Full-time',
    'Turn every workout, trainer story, and gym visit into content the whole country wants to watch.',
    [
      'Short-form native (TikTok/Reels)',
      'Sports/fitness fluency',
      'Analytics over vanity metrics',
    ],
  ),
];

const _values = <String>[
  'Consistency over intensity — in product and in people.',
  'Free where it matters. The buddy system never goes behind a paywall.',
  'Verified, not anonymous. Trust is the product.',
  'Built where it’s used — Nairobi first, then the world.',
];

class CareersScreen extends ConsumerStatefulWidget {
  const CareersScreen({super.key});

  @override
  ConsumerState<CareersScreen> createState() => _CareersScreenState();
}

class _CareersScreenState extends ConsumerState<CareersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _portfolio = TextEditingController();
  final _message = TextEditingController();
  String _role = _roles.first.title;
  bool _sending = false;
  bool _sent = false;
  String? _error;
  final _applyKey = GlobalKey();

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
    _portfolio.dispose();
    _message.dispose();
    super.dispose();
  }

  void _pickRole(String role) {
    setState(() {
      _role = role;
      _sent = false;
      _error = null;
    });
    final context = _applyKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
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
            '/waitlist/careers/',
            data: {
              'name': _name.text.trim(),
              'email': _email.text.trim(),
              'role': _role,
              'portfolio_url': _portfolio.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return InfoScaffold(
      title: 'Help a million people find their fitness family.',
      leadingIcon: LucideIcons.briefcase,
      subtitle:
          'We’re building the app that makes consistency social. Come build it with us — from Nairobi, for Kenya first, then the world.',
      children: [
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How we work',
                style: TextStyle(
                  color: BuddyColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final value in _values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          LucideIcons.check,
                          size: 15,
                          color: BuddyColors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: BuddyColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const InfoSectionTitle('Open roles'),
        for (final role in _roles)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          role.title,
                          style: const TextStyle(
                            color: BuddyColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BuddyColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: BuddyColors.green.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          role.type.toUpperCase(),
                          style: const TextStyle(
                            color: BuddyColors.green,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 12,
                        color: BuddyColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        role.location,
                        style: const TextStyle(
                          color: BuddyColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role.description,
                    style: const TextStyle(
                      color: BuddyColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final point in role.points)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              LucideIcons.check,
                              size: 13,
                              color: BuddyColors.green,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: BuddyColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _pickRole(role.title),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BuddyColors.green,
                      side: BorderSide(
                        color: BuddyColors.green.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply for this role',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          key: _applyKey,
          child: _sent
              ? InfoCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: BuddyColors.green.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          color: BuddyColors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application received',
                              style: TextStyle(
                                color: BuddyColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Thanks for applying — we reply to shortlisted candidates.',
                              style: TextStyle(
                                color: BuddyColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : InfoCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Apply now',
                          style: TextStyle(
                            color: BuddyColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        InfoDropdown(
                          label: 'Role',
                          value: _role,
                          options: [
                            for (final role in _roles) (role.title, role.title),
                          ],
                          onChanged: (v) => setState(() => _role = v),
                        ),
                        InfoTextField(
                          label: 'Full name',
                          controller: _name,
                          hint: 'Wanjiku Mwangi',
                          autofillHints: const [AutofillHints.name],
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'Tell us your name'
                              : null,
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
                        InfoTextField(
                          label: 'Portfolio / LinkedIn / GitHub (optional)',
                          controller: _portfolio,
                          hint: 'https://…',
                          keyboardType: TextInputType.url,
                        ),
                        InfoTextField(
                          label: 'Why you? (cover note)',
                          controller: _message,
                          maxLines: 5,
                          hint:
                              'Your experience, your fitness story, why BuddyUp Fit…',
                          validator: (v) => (v ?? '').trim().length < 10
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
                          label: _sending ? 'Sending…' : 'Submit application',
                          fullWidth: true,
                          isLoading: _sending,
                          onPressed: _sending ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        InfoLink(
          'Not seeing your role? Email careers@buddyupfit.com',
          icon: LucideIcons.mail,
          onTap: () => context.push('/contact'),
        ),
      ],
    );
  }
}
