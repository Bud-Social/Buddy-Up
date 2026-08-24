import 'dart:io';

void main() async {
  final dirs = ['lib/features/analytics/screens', 'lib/features/analytics/widgets'];
  for (final dir in dirs) {
    final d = Directory(dir);
    if (!await d.exists()) continue;
    
    await for (final file in d.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        var content = await file.readAsString();
        content = content.replaceAll('BuddyColors.surfaceRaised', 'Theme.of(context).colorScheme.surfaceContainerHighest');
        content = content.replaceAll('BuddyColors.surface', 'Theme.of(context).colorScheme.surface');
        content = content.replaceAll('BuddyColors.black', 'Theme.of(context).scaffoldBackgroundColor');
        
        await file.writeAsString(content);
        stderr.writeln('Updated ${file.path}');
      }
    }
  }
}
