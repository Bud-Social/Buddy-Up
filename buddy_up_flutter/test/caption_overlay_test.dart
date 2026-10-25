// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/shared/widgets/caption_overlay.dart';
import 'package:buddy_up_flutter/data/models/post.dart';

void main() {
  testWidgets('renders the active caption segment', (tester) async {
    final segments = [
      CaptionSegment(startMs: 0, endMs: 5000, text: 'Hello world'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptionOverlay(
            captions: segments,
            positionMs: 2500,
          ),
        ),
      ),
    );
    expect(find.text('Hello world'), findsOneWidget);
  });

  testWidgets('hides captions outside their time range', (tester) async {
    final segments = [
      CaptionSegment(startMs: 0, endMs: 2000, text: 'First line'),
      CaptionSegment(startMs: 3000, endMs: 6000, text: 'Second line'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptionOverlay(
            captions: segments,
            positionMs: 2500,
          ),
        ),
      ),
    );
    expect(find.text('First line'), findsNothing);
    expect(find.text('Second line'), findsNothing);
  });

  testWidgets('applies the style placement and clamps the size', (tester) async {
    final segments = [
      CaptionSegment(startMs: 0, endMs: 5000, text: 'Styled caption'),
    ];
    final style = {
      'preset': 'classic',
      'size': 2.0, // clamped to 1.6 max by CaptionOverlay
      'color': '#FFFFFF',
      'bg': 'block',
      'placement': 'center',
    };
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptionOverlay(
            captions: segments,
            positionMs: 2500,
            style: style,
          ),
        ),
      ),
    );
    expect(find.text('Styled caption'), findsOneWidget);
  });

  testWidgets('shows nothing when no caption is active', (tester) async {
    final segments = [
      CaptionSegment(startMs: 0, endMs: 1000, text: 'Gone'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CaptionOverlay(
            captions: segments,
            positionMs: 5000,
          ),
        ),
      ),
    );
    expect(find.text('Gone'), findsNothing);
  });
}
