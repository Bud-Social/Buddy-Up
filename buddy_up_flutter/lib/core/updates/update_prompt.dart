import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'app_update_service.dart';

enum _UpdatePhase { ready, downloading, done, error }

/// Silently checks for a newer sideloaded build on app start and offers an
/// in-app download + install. Renders nothing; iOS is excluded because its
/// updates come from the App Store.
class UpdatePrompt extends StatefulWidget {
  const UpdatePrompt({super.key});

  @override
  State<UpdatePrompt> createState() => _UpdatePromptState();
}

class _UpdatePromptState extends State<UpdatePrompt> {
  final AppUpdateService _service = AppUpdateService();

  @override
  void initState() {
    super.initState();
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    try {
      final update = await _service.check();
      if (!mounted || update == null) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateDialog(update: update, service: _service),
      );
    } catch (_) {
      // Offline or GitHub rate-limited: updates are best-effort, stay quiet.
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, required this.update, required this.service});

  final AppUpdateInfo update;
  final AppUpdateService service;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _UpdatePhase _phase = _UpdatePhase.ready;
  int _received = 0;
  int _total = 0;
  String? _path;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _phase = _UpdatePhase.downloading;
      _received = 0;
      _total = widget.update.size ?? 0;
    });
    try {
      final path = await widget.service.download(
        widget.update,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
      if (!mounted) return;
      setState(() {
        _path = path;
        _phase = _UpdatePhase.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _phase = _UpdatePhase.error;
      });
    }
  }

  Future<void> _install() async {
    if (_path == null) return;
    final result = await widget.service.install(_path!);
    if (!mounted) return;
    if (result.type == ResultType.error) {
      setState(() {
        _error = result.message.isNotEmpty
            ? result.message
            : 'Could not open the installer. Allow "Install unknown apps" for BuddyUp Fit in Settings.';
        _phase = _UpdatePhase.error;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    final progress = _total > 0 ? (_received / _total).clamp(0.0, 1.0) : null;

    return AlertDialog(
      title: const Text('Update available'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BuddyUp Fit ${update.version} is ready to download and install.',
            ),
            if (update.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                update.notes,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_phase == _UpdatePhase.downloading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text(
                progress == null
                    ? '${_formatBytes(_received)} downloaded'
                    : '${_formatBytes(_received)} / ${_formatBytes(_total)}  '
                        '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_phase == _UpdatePhase.error && _error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_phase == _UpdatePhase.done)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Download complete. Tap Install to finish.'),
              ),
          ],
        ),
      ),
      actions: [
        if (_phase != _UpdatePhase.downloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
        if (_phase == _UpdatePhase.ready)
          FilledButton(
            onPressed: _download,
            child: const Text('Download'),
          ),
        if (_phase == _UpdatePhase.error)
          FilledButton(
            onPressed: _download,
            child: const Text('Retry'),
          ),
        if (_phase == _UpdatePhase.done)
          FilledButton(
            onPressed: _install,
            child: const Text('Install'),
          ),
      ],
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
