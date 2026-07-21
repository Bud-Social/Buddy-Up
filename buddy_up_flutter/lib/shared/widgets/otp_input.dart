import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final void Function(String code) onCompleted;
  final bool enabled;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (index == widget.length - 1 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
      final code = _controllers.map((c) => c.text).join();
      if (code.length == widget.length) {
        widget.onCompleted(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 44,
          height: 52,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              color: BuddyColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: BuddyColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BuddyColors.green, width: 1.5),
              ),
            ),
            onChanged: (value) => _onChanged(index, value),
            onEditingComplete: () {},
          ),
        );
      }),
    );
  }
}
