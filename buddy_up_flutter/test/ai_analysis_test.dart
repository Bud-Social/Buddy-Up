import 'package:flutter_test/flutter_test.dart';
import 'package:buddy_up_flutter/data/models/post.dart';
import 'package:buddy_up_flutter/features/feed/widgets/ai_analysis_card.dart';
import 'package:flutter/material.dart';

void main() {
  test('Post.fromJson parses ai_analysis from snake_case key', () {
    final post = Post.fromJson({
      'id': 'p1',
      'authorData': {
        'username': 'u',
        'displayName': 'U',
        'avatarUrl': '',
        'verificationStatus': 'none',
      },
      'ai_analysis': {
        'text': {'toxicity_score': 0.01, 'label': 'not_toxic', 'method': 'model'},
        'images': [
          {'url': 'x.jpg', 'is_nsfw': false, 'confidence': 0.0, 'labels': ['clean'], 'method': 'model'}
        ],
      },
      'createdAt': '2026-01-01T00:00:00Z',
    });
    expect(post.aiAnalysis, isNotNull);
    expect(post.aiAnalysis!['text'], isNotNull);
  });

  test('Post.fromJson parses ai_analysis from camelCase key', () {
    final post = Post.fromJson({
      'id': 'p1',
      'authorData': {
        'username': 'u',
        'displayName': 'U',
        'avatarUrl': '',
        'verificationStatus': 'none',
      },
      'aiAnalysis': {
        'text': {'toxicity_score': 0.01, 'label': 'not_toxic', 'method': 'model'},
      },
      'createdAt': '2026-01-01T00:00:00Z',
    });
    expect(post.aiAnalysis, isNotNull);
  });

  testWidgets('AiAnalysisCard renders checks and Passed badge', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AiAnalysisCard(analysis: {
          'text': {'toxicity_score': 0.005, 'label': 'not_toxic', 'method': 'model'},
          'images': [
            {'url': 'x.jpg', 'is_nsfw': false, 'confidence': 0.0, 'labels': ['clean'], 'method': 'model'},
          ],
        }),
      ),
    ));
    expect(find.text('AI Analysis'), findsOneWidget);
    expect(find.text('Content check'), findsOneWidget);
    expect(find.text('Media check'), findsOneWidget);
    expect(find.text('Passed'), findsNWidgets(3));
  });

  testWidgets('AiAnalysisCard renders nothing when empty', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AiAnalysisCard(analysis: {})),
    ));
    expect(find.text('AI Analysis'), findsNothing);
  });
}
