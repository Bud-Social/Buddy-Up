import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:buddy_up_flutter/features/notifications/providers/notification_provider.dart';
import 'package:buddy_up_flutter/shared/navigation/main_header.dart';

/// The web shell keeps a hamburger, search and a badged notification bell on
/// every main tab. These tests lock the shared header to that contract.
void main() {
  Widget wrap(Widget child, {int unread = 0}) {
    return ProviderScope(
      overrides: [
        unreadCountProvider.overrideWith((ref) async => unread),
      ],
      child: MaterialApp(home: Scaffold(appBar: child as PreferredSizeWidget)),
    );
  }

  testWidgets('renders menu, search and bell, capped unread badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const MainAppBar(title: 'Discover People'), unread: 12),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.menu), findsOneWidget);
    expect(find.byIcon(LucideIcons.search), findsOneWidget);
    expect(find.byIcon(LucideIcons.bell), findsOneWidget);
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('no badge at zero unread', (tester) async {
    await tester.pumpWidget(
      wrap(const MainAppBar(title: 'Activities'), unread: 0),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.bell), findsOneWidget);
    expect(find.text('9+'), findsNothing);
  });

  testWidgets('logo replaces the title on Home', (tester) async {
    await tester.pumpWidget(
      wrap(const MainAppBar(showLogo: true), unread: 1),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/logo-dark.png');
    expect(find.text('Home'), findsNothing);
  });
}
