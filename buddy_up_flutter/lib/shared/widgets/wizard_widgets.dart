import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Shared multi-step wizard widgets reused across creation screens.

class WizardStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const WizardStepIndicator({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BuddyColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              height: 3,
              decoration: BoxDecoration(
                color: i <= current ? BuddyColors.green : BuddyColors.surfaceRaised,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class WizardNavButtons extends StatelessWidget {
  final int currentStep;
  final int total;
  final bool loading;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;
  final String submitLabel;

  const WizardNavButtons({
    super.key,
    required this.currentStep,
    required this.total,
    required this.loading,
    required this.onNext,
    required this.onBack,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: BuddyColors.green),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : currentStep < total - 1
                        ? onNext
                        : () => onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BuddyColors.green,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        currentStep < total - 1 ? 'Next' : submitLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WizardDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const WizardDateTimePicker({
    super.key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: onDateTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: BuddyColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 16, color: BuddyColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('${date.day}/${date.month}/${date.year}'),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: BuddyColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.access_time, size: 16, color: BuddyColors.textSecondary),
                const SizedBox(width: 8),
                Text(time.format(context)),
              ]),
            ),
          ),
        ]),
      ],
    );
  }
}

class WizardTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefix;
  final int maxLines;
  final TextInputType? inputType;

  const WizardTextField(
    this.label,
    this.controller, {
    super.key,
    this.hint,
    this.prefix,
    this.maxLines = 1,
    this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            filled: true,
            fillColor: BuddyColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
