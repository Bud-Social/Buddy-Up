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

  @GET('/marketplace/events/')
  Future<dynamic> getEvents({@Query('upcoming') bool? upcoming, @Query('scope') String? scope});

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
