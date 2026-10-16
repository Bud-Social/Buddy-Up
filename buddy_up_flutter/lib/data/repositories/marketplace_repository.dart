import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'marketplace_repository.g.dart';

@RestApi()
abstract class MarketplaceRepository {
  factory MarketplaceRepository(Dio dio, {String baseUrl}) = _MarketplaceRepository;

  @GET('/marketplace/meal-plans/')
  Future<dynamic> getMealPlans({@Query('diet_type') String? dietType});

  @POST('/marketplace/meal-plans/')
  Future<dynamic> createMealPlan(@Body() Map<String, dynamic> data);

  @GET('/marketplace/meal-plans/{id}/')
  Future<dynamic> getMealPlan(@Path('id') String planId);

  @PUT('/marketplace/meal-plans/{id}/')
  Future<dynamic> updateMealPlan(
    @Path('id') String planId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/meal-plans/{id}/')
  Future<void> deleteMealPlan(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/purchase/')
  Future<dynamic> purchaseMealPlan(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/personalise/')
  Future<dynamic> personaliseMealPlan(@Path('id') String planId);

  @GET('/marketplace/meal-plans/{id}/reviews/')
  Future<dynamic> getMealPlanReviews(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/reviews/')
  Future<dynamic> reviewMealPlan(
    @Path('id') String planId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/programmes/')
  Future<dynamic> getProgrammes({@Query('category') String? category});

  @POST('/marketplace/programmes/')
  Future<dynamic> createProgramme(@Body() Map<String, dynamic> data);

  @GET('/marketplace/programmes/{id}/')
  Future<dynamic> getProgramme(@Path('id') String programmeId);

  @PUT('/marketplace/programmes/{id}/')
  Future<dynamic> updateProgramme(
    @Path('id') String programmeId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/programmes/{id}/')
  Future<void> deleteProgramme(@Path('id') String programmeId);

  @POST('/marketplace/programmes/{id}/purchase/')
  Future<dynamic> purchaseProgramme(@Path('id') String programmeId);

  @GET('/marketplace/programmes/{id}/reviews/')
  Future<dynamic> getProgrammeReviews(@Path('id') String programmeId);

  @POST('/marketplace/programmes/{id}/reviews/')
  Future<dynamic> reviewProgramme(
    @Path('id') String programmeId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/products/')
  Future<dynamic> getProducts({@Query('category') String? category});

  @POST('/marketplace/products/')
  Future<dynamic> createProduct(@Body() Map<String, dynamic> data);

  @GET('/marketplace/products/{id}/')
  Future<dynamic> getProduct(@Path('id') String productId);

  @PUT('/marketplace/products/{id}/')
  Future<dynamic> updateProduct(
    @Path('id') String productId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/products/{id}/')
  Future<void> deleteProduct(@Path('id') String productId);

  @POST('/marketplace/products/{id}/click/')
  Future<void> clickProduct(@Path('id') String productId);

  /// Verified purchases only, and that is enforced by the shape of the write:
  /// a review hangs off an `OrderItem`, so a non-buyer has nothing to post
  /// against and gets a 404. The server also refuses a second review of the
  /// same order line, so there is no edit or delete to model here.
  @GET('/marketplace/products/{id}/reviews/')
  Future<dynamic> getProductReviews(@Path('id') String productId);

  @POST('/marketplace/products/{id}/reviews/')
  Future<dynamic> reviewProduct(
    @Path('id') String productId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/events/')
  Future<dynamic> getEvents({
    @Query('upcoming') bool? upcoming,
    @Query('scope') String? scope,
    @Query('q') String? query,
    @Query('lat') double? lat,
    @Query('lng') double? lng,
    @Query('radius_km') double? radiusKm,
  });

  @POST('/marketplace/events/')
  Future<dynamic> createEvent(@Body() Map<String, dynamic> data);

  @GET('/marketplace/events/{id}/')
  Future<dynamic> getEvent(@Path('id') String eventId);

  @PUT('/marketplace/events/{id}/')
  Future<dynamic> updateEvent(
    @Path('id') String eventId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/events/{id}/')
  Future<void> deleteEvent(@Path('id') String eventId);

  @POST('/marketplace/events/{id}/tickets/')
  Future<dynamic> purchaseEventTicket(@Path('id') String eventId);

  @GET('/marketplace/events/my-tickets/')
  Future<dynamic> getMyTickets();

  @GET('/marketplace/events/tickets/{id}/')
  Future<dynamic> getTicket(@Path('id') String ticketId);

  @POST('/marketplace/food-recognize/')
  Future<dynamic> recognizeFood(@Body() FormData data);

  @GET('/marketplace/my-services/')
  Future<dynamic> getMyServices();

  @GET('/marketplace/my-services/analytics/')
  Future<dynamic> getCreatorAnalytics();

  @GET('/marketplace/cart/')
  Future<dynamic> getCart();

  @POST('/marketplace/cart/')
  Future<dynamic> addToCart(@Body() Map<String, dynamic> data);

  @DELETE('/marketplace/cart/')
  Future<void> removeFromCart(@Body() Map<String, dynamic> data);

  @POST('/marketplace/cart/checkout/')
  Future<dynamic> checkoutCart([@Body() Map<String, dynamic>? data]);

  @POST('/marketplace/cart/discount/')
  Future<dynamic> applyDiscount(@Body() Map<String, dynamic> data);

  @DELETE('/marketplace/cart/discount/')
  Future<void> removeDiscount();

  // --- Fulfillment logistics ---
  // `distance_km` is only computed when both `lat` and `lng` are supplied, so a
  // caller with no location gets a list with no distances at all. That is a
  // degraded case, not an error — see features/marketplace/utils/stations.dart.
  @GET('/marketplace/stations/')
  Future<dynamic> getStations({
    @Query('lat') double? lat,
    @Query('lng') double? lng,
    @Query('radius_km') double? radiusKm,
    @Query('owner_type') String? ownerType,
    @Query('q') String? query,
  });

  @GET('/marketplace/stations/{id}/')
  Future<dynamic> getStation(@Path('id') String stationId);

  @POST('/marketplace/stations/')
  Future<dynamic> createStation(@Body() Map<String, dynamic> data);

  @PATCH('/marketplace/stations/{id}/')
  Future<dynamic> updateStation(
    @Path('id') String stationId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/marketplace/station-applications/')
  Future<dynamic> applyForStation(@Body() Map<String, dynamic> data);

  // --- Courier dashboard ---
  //
  // All four are scoped to the *signed-in* courier rather than taking an id, so
  // `getCourierSummary()` 404ing means the caller has no `DeliveryPersonnel` row
  // at all — "not registered", not "no data". Callers must branch on that.
  @GET('/marketplace/delivery/summary/')
  Future<dynamic> getCourierSummary();

  // `status` is validated server-side (a 400 naming the legal values), so a blank
  // string is dropped rather than sent as a filter that matches nothing.
  @GET('/marketplace/delivery/my-orders/')
  Future<dynamic> getCourierOrders({
    @Query('status') String? status,
    @Query('page') int? page,
  });

  /// Only the four `COURIER_TRANSITIONS` moves are accepted; anything else is a
  /// 400 that names the illegal move. Carrying carrier / tracking / pickup keys
  /// is a 403 — shipping metadata stays with the seller.
  @PATCH('/marketplace/delivery/my-orders/{id}/')
  Future<dynamic> updateCourierOrderStatus(
    @Path('id') String orderId,
    @Body() Map<String, dynamic> data,
  );

  /// An *estimate* from completed orders. Not a balance, not a payout.
  @GET('/marketplace/delivery/earnings/')
  Future<dynamic> getCourierEarnings({
    @Query('from') String? from,
    @Query('to') String? to,
  });

  @POST('/marketplace/delivery-personnel/')
  Future<dynamic> saveDeliveryPersonnel(@Body() Map<String, dynamic> data);

  @POST('/marketplace/delivery-personnel-applications/')
  Future<dynamic> applyAsDeliveryPersonnel(@Body() Map<String, dynamic> data);

  // --- Event organiser ---
  //
  // 403 for anyone who is not an organiser. That is an expected state (the nav
  // only shows the entry when it resolves true), so callers turn it into a
  // readable message rather than an empty list.
  @GET('/marketplace/events/mine/')
  Future<dynamic> getOrganisedEvents();

  // Filters are validated, not ignored: an unknown `status` is a 400 rather than
  // a silently unfiltered list.
  @GET('/marketplace/events/{id}/attendees/')
  Future<dynamic> getEventAttendees(
    @Path('id') String eventId, {
    @Query('checked_in') bool? checkedIn,
    @Query('status') String? status,
    @Query('tier') String? tier,
    @Query('page') int? page,
  });

  /// 404 unknown code · 409 already checked in (message names the time) ·
  /// 400 cancelled or refunded ticket.
  @POST('/marketplace/events/{id}/check-in/')
  Future<dynamic> checkInAttendee(
    @Path('id') String eventId,
    @Body() Map<String, dynamic> data,
  );

  /// Reverses a mistaken check-in; 409 when the ticket was never checked in.
  @POST('/marketplace/events/{id}/check-out/')
  Future<dynamic> checkOutAttendee(
    @Path('id') String eventId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/events/{id}/stats/')
  Future<dynamic> getEventStats(@Path('id') String eventId);

  // Real-money settlement for an order that already exists.
  @POST('/marketplace/orders/payment-intents/')
  Future<dynamic> createPaymentIntent(@Body() Map<String, dynamic> data);

  @GET('/marketplace/orders/seller/{id}/couriers/')
  Future<dynamic> getOrderCouriers(@Path('id') String orderId);

  @GET('/marketplace/orders/')
  Future<dynamic> getOrders({@Query('status') String? status});

  @GET('/marketplace/orders/seller/')
  Future<dynamic> getSellerOrders({@Query('status') String? status});

  @GET('/marketplace/orders/{id}/')
  Future<dynamic> getOrder(@Path('id') String orderId);

  @PATCH('/marketplace/orders/{id}/fulfillment/')
  Future<dynamic> updateOrderFulfillment(
    @Path('id') String orderId,
    @Body() Map<String, dynamic> data,
  );

  @PATCH('/marketplace/orders/{id}/status/')
  Future<dynamic> updateOrderStatus(
    @Path('id') String orderId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/discount-codes/')
  Future<dynamic> getDiscountCodes();

  @GET('/marketplace/discount-codes/{id}/')
  Future<dynamic> getDiscountCode(@Path('id') String codeId);

  @POST('/marketplace/discount-codes/')
  Future<dynamic> createDiscountCode(@Body() Map<String, dynamic> data);

  @PUT('/marketplace/discount-codes/{id}/')
  Future<dynamic> updateDiscountCode(
    @Path('id') String codeId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/discount-codes/{id}/')
  Future<void> deleteDiscountCode(@Path('id') String codeId);

  @PATCH('/marketplace/discount-codes/{id}/')
  Future<dynamic> patchDiscountCode(
    @Path('id') String codeId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/discount-codes/{id}/analytics/')
  Future<dynamic> getDiscountCodeAnalytics(@Path('id') String codeId);

  @POST('/marketplace/discount-codes/{id}/share/')
  Future<dynamic> shareDiscountCode(@Path('id') String codeId);

  @GET('/marketplace/shops/my/')
  Future<dynamic> getMyShops();

  @POST('/marketplace/register-creator/')
  Future<dynamic> registerCreator(@Body() Map<String, dynamic> data);

  @POST('/marketplace/shops/')
  Future<dynamic> createShop(@Body() Map<String, dynamic> data);

  @GET('/marketplace/shops/{handle}/')
  Future<dynamic> getShop(@Path('handle') String handle);

  @GET('/marketplace/shops/{handle}/public/')
  Future<dynamic> getUserShop(@Path('handle') String handle);

  @PUT('/marketplace/shops/{handle}/')
  Future<dynamic> updateShop(
    @Path('handle') String handle,
    @Body() Map<String, dynamic> data,
  );

  @POST('/marketplace/shops/{handle}/verify/')
  Future<dynamic> submitShopVerification(
    @Path('handle') String handle,
    @Body() Map<String, dynamic> data,
  );

  @POST('/marketplace/upload-cover/')
  Future<dynamic> uploadImage(@Body() FormData data);
}
