import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';

/// Toggle that records the device screen + mic while in a call — the Flutter
/// counterpart of the web's "screen record with audio" control. Hidden on
/// platforms the plugin doesn't support (desktop except web).
///
/// Stopping saves a local file; native platforms surface it in the share
/// sheet, web triggers the browser download. The plugin records the whole
/// screen, not a composited call layout — same semantics as the web capture.
class ScreenRecordButton extends StatefulWidget {
  const ScreenRecordButton({super.key});

  @override
  State<ScreenRecordButton> createState() => _ScreenRecordButtonState();
}

class _ScreenRecordButtonState extends State<ScreenRecordButton> {
  bool _recording = false;
  bool _busy = false;

  /// The plugin implements Android (MediaProjection), iOS (ReplayKit) and
  /// Web (getDisplayMedia). Desktop platforms get no implementation — hide.
  static bool get _supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_recording) {
        final path = await FlutterScreenRecording.stopRecordScreen;
        if (!mounted) return;
        setState(() => _recording = false);
        _announceSaved(path);
        return;
      }

      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to record with audio')),
          );
        }
        return;
      }
      // Android 13+ needs the notification permission for the foreground
      // service; the recording still works without it on older versions.
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      final started = await FlutterScreenRecording.startRecordScreenAndAudio(
        'buddyup_${DateTime.now().millisecondsSinceEpoch}',
        titleNotification: 'Screen recording',
        messageNotification: 'Buddy Up is recording this screen',
      );
      if (!mounted) return;
      if (started) {
        setState(() => _recording = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start the screen recording')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen recording is not available here')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _announceSaved(String path) {
    if (!mounted) return;
    final isPath = path.isNotEmpty && (path.contains('/') || path.contains('\\'));
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(isPath ? 'Screen recording saved' : 'Screen recording finished'),
        action: isPath
            ? SnackBarAction(
                label: 'Share',
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Buddy Up screen recording',
                      files: [XFile(path)],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  @override
  void dispose() {
    // If the screen goes away while recording, stop it so no orphan capture
    // keeps draining storage and battery in the background.
    if (_recording) {
      FlutterScreenRecording.stopRecordScreen.catchError((_) => '');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: _recording ? BuddyColors.red : Colors.white24,
          foregroundColor: Colors.white,
          onPressed: _toggle,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(_recording ? Icons.stop_circle : Icons.fiber_manual_record),
        ),
        const SizedBox(height: 6),
        Text(
          _recording ? 'REC' : 'Record',
          style: TextStyle(
            color: _recording ? Colors.redAccent : BuddyColors.textSecondary,
            fontSize: 12,
            fontWeight: _recording ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
