import 'package:buddy_up_flutter/data/models/marketplace.dart';
import 'package:flutter_test/flutter_test.dart';

/// The product-review and stock wire contract.
///
/// Three payloads are pinned here because each one changed shape and each is read
/// by a screen that would otherwise silently render zeros: the product row
/// (`ProductSerializer`), the review list (`ProductReviewView.get`), and the Shop
/// dashboard's new `product_performance` block (`CreatorAnalyticsView`).
///
/// The recurring hazard is the default. A stock field with no default reads a
/// pre-tracking server as "0 in stock" — i.e. as sold out — so every new field
/// here must default to the *permissive* answer, and that is what these tests
/// actually check.
void main() {
  Map<String, dynamic> product(Map<String, dynamic> overrides) => {
        'id': 'p1',
        'name': 'Whey Isolate',
        'brand': 'Iron Temple',
        'description': 'Unflavoured isolate.',
        'category': 'supplement',
        'image_url': 'https://cdn.example.com/whey.png',
        'affiliate_url': 'https://shop.example.com/whey',
        'price_display': r'$29',
        'created_at': '2026-09-01T10:00:00Z',
        ...overrides,
      };

  group('the product row carries its rating and stock', () {
    test('every field the screens read is parsed', () {
      final parsed = MarketplaceProduct.fromJson(product({
        'average_rating': 4.5,
        'review_count': 12,
        'stock_quantity': 3,
        'stock_tracking_enabled': true,
      }));

      expect(parsed.averageRating, 4.5);
      expect(parsed.reviewCount, 12);
      expect(parsed.stockQuantity, 3);
      expect(parsed.stockTrackingEnabled, isTrue);
    });

    test('an older server that sends none of them reads as unlimited stock', () {
      // The failure this guards: defaulting `stock_quantity` to 0 without
      // respecting the tracking flag would mark every legacy product sold out
      // and take away a working Add to Cart button.
      final parsed = MarketplaceProduct.fromJson(product({}));
      expect(parsed.stockTrackingEnabled, isFalse);
      expect(parsed.stockQuantity, 0);
      expect(parsed.reviewCount, 0);
      expect(parsed.averageRating, 0.0);
    });

    test('a zero rating with a non-zero count is still shown', () {
      // `average_rating` is only meaningful next to `review_count`; the screen
      // keys off the count, so the two must be able to disagree without the
      // model hiding it.
      final parsed =
          MarketplaceProduct.fromJson(product({'average_rating': 0.0, 'review_count': 4}));
      expect(parsed.reviewCount, 4);
      expect(parsed.averageRating, 0.0);
    });
  });

  group('a review parses from the serializer that produced it', () {
    test('the body shape of ProductReviewSerializer', () {
      final review = ProductReview.fromJson({
        'id': 'r1',
        'rating': 4,
        'body': 'Mixes clean.',
        'buyer_data': {
          'username': 'sam',
          'display_name': 'Sam O.',
          'avatar_url': '',
        },
        'created_at': '2026-10-01T12:00:00Z',
      });

      expect(review.id, 'r1');
      expect(review.rating, 4);
      expect(review.body, 'Mixes clean.');
      expect(review.buyerData.username, 'sam');
      expect(review.buyerData.displayName, 'Sam O.');
      expect(review.buyerData.avatarUrl, isEmpty);
    });

    test('a rating-only review with no body text is not unparseable', () {
      // `body` is `blank=True` and the screen hides the paragraph when empty, so
      // an empty string must survive the round trip rather than throwing.
      final review = ProductReview.fromJson({
        'id': 'r2',
        'rating': 5,
        'body': '',
        'buyer_data': {
          'username': 'kim',
          'display_name': '',
          'avatar_url': '',
        },
        'created_at': '2026-10-02T12:00:00Z',
      });

      expect(review.rating, 5);
      expect(review.body, isEmpty);
      expect(review.buyerData.displayName, isEmpty,
          reason: 'the tile falls back to username when this is blank');
    });
  });

  group('the Shop dashboard parses product_performance', () {
    Map<String, dynamic> analytics(List<Map<String, dynamic>> performance) => {
          'total_revenue_usd': 120.5,
          'total_sales': 3,
          'total_views': 40,
          'category_sales': {'product': 3},
          'category_revenue': {'product': 120.5},
          'revenue_over_time': const [],
          'top_services': const [],
          'product_performance': performance,
        };

    test('a full row is parsed field for field', () {
      final parsed = CreatorAnalytics.fromJson(analytics([
        {
          'id': 'p1',
          'title': 'Whey Isolate',
          'clicks': 200,
          'units_sold': 12,
          'revenue_usd': 348.0,
          'conversion_rate': 6.0,
          'average_rating': 4.5,
          'review_count': 12,
          'stock_quantity': 3,
          'stock_tracking_enabled': true,
        },
      ]));

      expect(parsed.productPerformance, hasLength(1));
      final row = parsed.productPerformance.single;
      expect(row.id, 'p1');
      expect(row.title, 'Whey Isolate');
      expect(row.clicks, 200);
      expect(row.unitsSold, 12);
      expect(row.revenueUsd, 348.0);
      expect(row.conversionRate, 6.0);
      expect(row.averageRating, 4.5);
      expect(row.reviewCount, 12);
      expect(row.stockQuantity, 3);
      expect(row.stockTrackingEnabled, isTrue);
      expect(row.isSoldOut, isFalse);
    });

    test('a server without the block still parses, with no rows to show', () {
      // The card is hidden on an empty list, so a missing key must degrade to
      // "nothing to show" rather than crashing the whole analytics tab.
      final parsed = CreatorAnalytics.fromJson({
        'total_revenue_usd': 0,
        'total_sales': 0,
        'total_views': 0,
        'category_sales': <String, dynamic>{},
        'category_revenue': <String, dynamic>{},
        'revenue_over_time': const [],
        'top_services': const [],
      });

      expect(parsed.productPerformance, isEmpty);
    });

    test('a tracked product at zero is sold out; an untracked one is not', () {
      final rows = [
        ProductPerformance.fromJson({'stock_quantity': 0, 'stock_tracking_enabled': true}),
        ProductPerformance.fromJson({'stock_quantity': 0, 'stock_tracking_enabled': false}),
      ];
      expect(rows[0].isSoldOut, isTrue);
      expect(rows[1].isSoldOut, isFalse,
          reason: 'an untracked product has a meaningless stock_quantity of 0');
    });

    test('the rest of the analytics payload is untouched by the new block', () {
      // The product block was added alongside the existing totals, not in place of
      // them, so a caller of this provider still gets its numbers.
      final parsed = CreatorAnalytics.fromJson(analytics(const []));
      expect(parsed.totalRevenueUsd, 120.5);
      expect(parsed.totalSales, 3);
      expect(parsed.totalViews, 40);
      expect(parsed.categorySales, {'product': 3});
    });
  });

  group('the shop role travels on the row it describes', () {
    test('shops/my/ carries my_role, and other endpoints simply omit it', () {
      // `Shop` is reused by list, detail and `shops/my/`; only the last sends
      // `my_role`, and the permissions gate reads it to decide who may publish.
      final mine = Shop.fromJson({
        'id': 's1',
        'handle': 'iron-goods',
        'name': 'Iron Temple Goods',
        'my_role': 'owner',
      });
      final public = Shop.fromJson({
        'id': 's1',
        'handle': 'iron-goods',
        'name': 'Iron Temple Goods',
      });

      expect(mine.myRole, 'owner');
      expect(public.myRole, isEmpty,
          reason: 'an absent role must never read as owner');
    });
  });
}