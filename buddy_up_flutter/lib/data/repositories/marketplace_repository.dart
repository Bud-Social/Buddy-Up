import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'marketplace_repository.g.dart';

@RestApi()
abstract class MarketplaceRepository {
  factory MarketplaceRepository(Dio dio, {String baseUrl}) = _MarketplaceRepository;

  @GET('/marketplace/meal-plans/')
  Future<Map<String, dynamic>> getMealPlans({@Query('diet_type') String? dietType});

  @POST('/marketplace/meal-plans/')
  Future<Map<String, dynamic>> createMealPlan(@Body() Map<String, dynamic> data);

  @GET('/marketplace/meal-plans/{id}/')
  Future<Map<String, dynamic>> getMealPlan(@Path('id') String planId);

  @PUT('/marketplace/meal-plans/{id}/')
  Future<Map<String, dynamic>> updateMealPlan(
    @Path('id') String planId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/meal-plans/{id}/')
  Future<void> deleteMealPlan(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/purchase/')
  Future<Map<String, dynamic>> purchaseMealPlan(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/personalise/')
  Future<Map<String, dynamic>> personaliseMealPlan(@Path('id') String planId);

  @GET('/marketplace/meal-plans/{id}/reviews/')
  Future<Map<String, dynamic>> getMealPlanReviews(@Path('id') String planId);

  @POST('/marketplace/meal-plans/{id}/reviews/')
  Future<Map<String, dynamic>> reviewMealPlan(
    @Path('id') String planId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/programmes/')
  Future<Map<String, dynamic>> getProgrammes({@Query('category') String? category});

  @POST('/marketplace/programmes/')
  Future<Map<String, dynamic>> createProgramme(@Body() Map<String, dynamic> data);

  @GET('/marketplace/programmes/{id}/')
  Future<Map<String, dynamic>> getProgramme(@Path('id') String programmeId);

  @PUT('/marketplace/programmes/{id}/')
  Future<Map<String, dynamic>> updateProgramme(
    @Path('id') String programmeId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/programmes/{id}/')
  Future<void> deleteProgramme(@Path('id') String programmeId);

  @POST('/marketplace/programmes/{id}/purchase/')
  Future<Map<String, dynamic>> purchaseProgramme(@Path('id') String programmeId);

  @GET('/marketplace/programmes/{id}/reviews/')
  Future<Map<String, dynamic>> getProgrammeReviews(@Path('id') String programmeId);

  @POST('/marketplace/programmes/{id}/reviews/')
  Future<Map<String, dynamic>> reviewProgramme(
    @Path('id') String programmeId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/marketplace/products/')
  Future<Map<String, dynamic>> getProducts({@Query('category') String? category});

  @POST('/marketplace/products/')
  Future<Map<String, dynamic>> createProduct(@Body() Map<String, dynamic> data);

  @GET('/marketplace/products/{id}/')
  Future<Map<String, dynamic>> getProduct(@Path('id') String productId);

  @PUT('/marketplace/products/{id}/')
  Future<Map<String, dynamic>> updateProduct(
    @Path('id') String productId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/products/{id}/')
  Future<void> deleteProduct(@Path('id') String productId);

  @POST('/marketplace/products/{id}/click/')
  Future<void> clickProduct(@Path('id') String productId);

  @GET('/marketplace/events/')
  Future<Map<String, dynamic>> getEvents({@Query('upcoming') bool? upcoming});

  @POST('/marketplace/events/')
  Future<Map<String, dynamic>> createEvent(@Body() Map<String, dynamic> data);

  @GET('/marketplace/events/{id}/')
  Future<Map<String, dynamic>> getEvent(@Path('id') String eventId);

  @PUT('/marketplace/events/{id}/')
  Future<Map<String, dynamic>> updateEvent(
    @Path('id') String eventId,
    @Body() Map<String, dynamic> data,
  );

  @DELETE('/marketplace/events/{id}/')
  Future<void> deleteEvent(@Path('id') String eventId);

  @POST('/marketplace/events/{id}/tickets/')
  Future<Map<String, dynamic>> purchaseEventTicket(@Path('id') String eventId);

  @GET('/marketplace/events/my-tickets/')
  Future<Map<String, dynamic>> getMyTickets();

  @GET('/marketplace/events/tickets/{id}/')
  Future<Map<String, dynamic>> getTicket(@Path('id') String ticketId);

  @POST('/marketplace/food-recognize/')
  Future<Map<String, dynamic>> recognizeFood(@Body() FormData data);

  @GET('/marketplace/my-services/')
  Future<Map<String, dynamic>> getMyServices();

  @GET('/marketplace/cart/')
  Future<Map<String, dynamic>> getCart();

  @POST('/marketplace/cart/')
  Future<Map<String, dynamic>> addToCart(@Body() Map<String, dynamic> data);

  @DELETE('/marketplace/cart/')
  Future<void> removeFromCart(@Body() Map<String, dynamic> data);

  @POST('/marketplace/cart/checkout/')
  Future<Map<String, dynamic>> checkoutCart();

  @POST('/marketplace/cart/discount/')
  Future<Map<String, dynamic>> applyDiscount(@Body() Map<String, dynamic> data);
}
