import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../data/models/marketplace.dart';
import '../../../core/api/api_client.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final dio = ref.watch(apiClientProvider5).dio;
  return MarketplaceRepository(dio);
});

final apiClientProvider5 = Provider<ApiClient>((_) => ApiClient());

List<MealPlan> _parseMealPlanList(dynamic data) =>
    (data as List).map((e) => MealPlan.fromJson(e as Map<String, dynamic>)).toList();

List<TrainingProgramme> _parseProgrammeList(dynamic data) =>
    (data as List).map((e) => TrainingProgramme.fromJson(e as Map<String, dynamic>)).toList();

List<MarketplaceProduct> _parseProductList(dynamic data) =>
    (data as List).map((e) => MarketplaceProduct.fromJson(e as Map<String, dynamic>)).toList();

List<MarketplaceEvent> _parseEventList(dynamic data) =>
    (data as List).map((e) => MarketplaceEvent.fromJson(e as Map<String, dynamic>)).toList();

// -- Meal Plan Providers --
final mealPlansProvider = FutureProvider<List<MealPlan>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getMealPlans();
  return _parseMealPlanList(raw['data']);
});

final mealPlanDetailProvider = FutureProvider.family<MealPlan, String>((ref, planId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getMealPlan(planId);
  return MealPlan.fromJson(raw['data'] as Map<String, dynamic>);
});

final mealPlanReviewsProvider = FutureProvider.family<List<MealPlanReview>, String>((ref, planId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getMealPlanReviews(planId);
  return (raw['data'] as List)
      .map((e) => MealPlanReview.fromJson(e as Map<String, dynamic>))
      .toList();
});

// -- Programme Providers --
final programmesProvider = FutureProvider<List<TrainingProgramme>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getProgrammes();
  return _parseProgrammeList(raw['data']);
});

final programmeDetailProvider = FutureProvider.family<TrainingProgramme, String>((ref, programmeId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getProgramme(programmeId);
  return TrainingProgramme.fromJson(raw['data'] as Map<String, dynamic>);
});

// -- Product Providers --
final productsProvider = FutureProvider<List<MarketplaceProduct>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getProducts();
  return _parseProductList(raw['data']);
});

final productDetailProvider = FutureProvider.family<MarketplaceProduct, String>((ref, productId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getProduct(productId);
  return MarketplaceProduct.fromJson(raw['data'] as Map<String, dynamic>);
});

// -- Event Providers --
final eventsProvider = FutureProvider<List<MarketplaceEvent>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getEvents(upcoming: true);
  return _parseEventList(raw['data']);
});

final eventDetailProvider = FutureProvider.family<MarketplaceEvent, String>((ref, eventId) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getEvent(eventId);
  return MarketplaceEvent.fromJson(raw['data'] as Map<String, dynamic>);
});

final myTicketsProvider = FutureProvider<List<EventTicket>>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getMyTickets();
  return (raw['data'] as List)
      .map((e) => EventTicket.fromJson(e as Map<String, dynamic>))
      .toList();
});

// -- Cart Provider --
class CartNotifier extends Notifier<AsyncValue<Cart?>> {
  @override
  AsyncValue<Cart?> build() => const AsyncData(null);

  MarketplaceRepository get _repo => ref.read(marketplaceRepositoryProvider);

  Future<void> loadCart() async {
    state = const AsyncLoading();
    try {
      final raw = await _repo.getCart();
      state = AsyncData(Cart.fromJson(raw['data'] as Map<String, dynamic>));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addToCart(String itemType, Map<String, dynamic> idData, {int quantity = 1}) async {
    try {
      await _repo.addToCart({...idData, 'item_type': itemType, 'quantity': quantity});
      await loadCart();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeFromCart(String? itemId) async {
    try {
      await _repo.removeFromCart({'item_id': itemId});
      await loadCart();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> applyDiscount(String code) async {
    try {
      await _repo.applyDiscount({'code': code});
      await loadCart();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, AsyncValue<Cart?>>(CartNotifier.new);

// -- Creator Services --
final creatorServicesProvider = FutureProvider<CreatorServices>((ref) async {
  final repo = ref.watch(marketplaceRepositoryProvider);
  final raw = await repo.getMyServices();
  return CreatorServices.fromJson(raw['data'] as Map<String, dynamic>);
});
