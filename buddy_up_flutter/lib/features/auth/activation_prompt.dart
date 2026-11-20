import 'package:flutter/material.dart';

/// New social accounts are created but held until the activation email is
/// opened. Show a clear next step instead of treating the 201 response as a
/// failed sign-in.
Future<void> showActivationRequired(BuildContext context, String? email) {
  final target = (email == null || email.isEmpty) ? '' : ' for $email';
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Check your email'),
      content: Text(
        'We created your BuddyUp Fit account$target. Open the activation link '
        'we just sent you, then sign in again to continue.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
