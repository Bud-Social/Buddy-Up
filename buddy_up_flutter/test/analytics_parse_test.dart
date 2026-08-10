import 'dart:convert';
import 'dart:io';

import 'package:buddy_up_flutter/data/models/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AnalyticsSummaryData parses real backend response', () {
    final file = File('test/fixtures_analytics_summary.json');
    if (!file.existsSync()) {
      markTestSkipped('no live summary fixture');
      return;
    }
    final body = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    final summary = AnalyticsSummaryData.fromJson(data);

    expect(summary.period, isNotNull);
    expect(summary.user.username, isNotEmpty);
    expect(summary.workouts.count, greaterThanOrEqualTo(0));
    expect(summary.workouts.totalCaloriesBurned, greaterThanOrEqualTo(0));
    expect(summary.workouts.totalVolume, greaterThanOrEqualTo(0));
    expect(summary.workouts.mostTrained, isNotNull);
    expect(summary.activity.totalDistanceKm, greaterThanOrEqualTo(0));
    expect(summary.nutrition.totalCalories, greaterThanOrEqualTo(0));
    expect(summary.nutrition.totalProteinG, greaterThanOrEqualTo(0));
    expect(summary.nutrition.totalCarbsG, greaterThanOrEqualTo(0));
    expect(summary.nutrition.totalFatG, greaterThanOrEqualTo(0));
    expect(summary.body.startWeightKg, greaterThanOrEqualTo(0));
    expect(summary.body.latestWeightKg, greaterThanOrEqualTo(0));
    expect(summary.spending.giftsSent.category, isNotNull);
    expect(summary.programmes.programmesPurchased, greaterThanOrEqualTo(0));
  });
}
