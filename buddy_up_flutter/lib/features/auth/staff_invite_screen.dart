import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/api/api_client.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/admin_portal_repository.dart';
import '../../../shared/widgets/button.dart';

/// Web `AcceptStaffInvite.tsx` — `/staff-invite/:token`.
///
/// A live invitation can be claimed only by the invited email address. The
/// server enforces the match; this screen explains the four states clearly so
/// a forwarded or expired link never looks like a broken app.
class StaffInviteScreen extends ConsumerStatefulWidget {
  final String token;

  const StaffInviteScreen({super.key, required this.token});

  @override
  ConsumerState<StaffInviteScreen> createState() => _StaffInviteScreenState();
}

class _StaffInviteScreenState extends ConsumerState<StaffInviteScreen> {
  late final AdminPortalRepository _repo = AdminPortalRepository(
    ApiClient().dio,
  );

  bool _loading = true;
  bool _busy = false;
  String? _usuableMessage;
  String? _error;
  Map<String, dynamic>? _invite;
  bool _claimed = false;
  String? _signedInAs;

  @override
  void initState() {
    super.initState();
    _signedInAs = ref.read(authProvider).user?.email;
    _load();
  }

  Future<void> _load() async {
    if (widget.token.isEmpty) {
      setState(() {
        _loading = false;
        _usuableMessage = 'This link is missing its invitation code.';
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _repo.getStaffInvitationPreview(widget.token);
      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      if (data['is_live'] != true) {
        final status = data['status'] as String?;
        final message = switch (status) {
          'expired' =>
            'This invitation has expired. Ask whoever invited you for a new one.',
          'revoked' => 'This invitation was withdrawn.',
          'accepted' => 'This invitation has already been used.',
          _ => 'This invitation is no longer valid.',
        };
        setState(() {
          _usuableMessage = message;
          _loading = false;
        });
        return;
      }
      setState(() {
        _invite = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _usuableMessage = 'This invitation link could not be read.';
        _loading = false;
      });
    }
  }

  bool get _wrongAccount {
    final invite = _invite;
    final signed = _signedInAs;
    if (invite == null || signed == null || signed.isEmpty) return false;
    return signed.toLowerCase() != (invite['email'] as String?)?.toLowerCase();
  }

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.acceptStaffInvitation(widget.token);
      if (mounted) setState(() => _claimed = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not accept this invitation.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Staff invitation'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BuddyColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.shieldCheck,
                      size: 40,
                      color: BuddyColors.green,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Staff invitation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: BuddyColors.green,
                          ),
                        ),
                      )
                    else if (_claimed)
                      const Text(
                        'Invitation accepted — your staff role is active.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: BuddyColors.green,
                          fontSize: 14,
                        ),
                      )
                    else if (_usuableMessage != null)
                      Text(
                        _usuableMessage!,
                        style: const TextStyle(
                          color: BuddyColors.orange,
                          fontSize: 13,
                        ),
                      )
                    else if (_wrongAccount) ...[
                      Text(
                        'You are signed in as $_signedInAs, but this invitation was sent to ${_invite?['email']}.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign out and sign back in with the invited address to accept it. This check stops a forwarded link from granting access to the wrong person.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BuddyButton(
                        label: 'Sign in with another account',
                        fullWidth: true,
                        onPressed: () => context.go('/login'),
                      ),
                    ] else if (_invite != null) ...[
                      Text(
                        'You have been invited to join the BuddyUp Fit staff as ${_invite?['role_display'] ?? _invite?['role']}.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invitation for ${_invite?['email']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                        ),
                      ),
                      if (_signedInAs == null || _signedInAs!.isEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Sign in with the invited address to claim this invitation.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        BuddyButton(
                          label: 'Sign in',
                          fullWidth: true,
                          onPressed: () => context.go(
                            '/login?next=${Uri.encodeComponent('/staff-invite/${widget.token}')}',
                          ),
                        ),
                      ] else ...[
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: BuddyColors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        BuddyButton(
                          label: _busy ? 'Accepting…' : 'Accept invitation',
                          fullWidth: true,
                          isLoading: _busy,
                          onPressed: _busy ? null : _accept,
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/feed'),
                      child: const Text('Go to Buddy Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
