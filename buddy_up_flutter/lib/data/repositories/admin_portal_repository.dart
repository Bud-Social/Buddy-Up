import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'admin_portal_repository.g.dart';

/// Typed client for `/api/v1/portal/**`, mirroring
/// `frontend/src/api/adminPortal.ts` path-for-path.
///
/// Every method returns the raw `{success, data, message, errors, pagination}`
/// envelope (unwrapped one level, not `data.data`) and every list takes an
/// optional filter map passed straight through as query params — same
/// convention as `MarketplaceRepository`.
///
/// This surface is read-mostly by design: it is the mobile shadow of the web
/// admin console, not a second moderation desk. Nothing here deletes a row and
/// nothing here writes the wallet ledger.
@RestApi()
abstract class AdminPortalRepository {
  factory AdminPortalRepository(Dio dio, {String baseUrl}) = _AdminPortalRepository;

  // --- Users ---
  @GET('/portal/users/')
  Future<dynamic> getUsers({
    @Query('q') String? query,
    @Query('role') String? role,
    @Query('is_active') bool? isActive,
    @Query('verification_status') String? verificationStatus,
    @Query('has_search_profile') bool? hasSearchProfile,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/users/{id}/')
  Future<dynamic> getUser(@Path('id') String userId);

  @PATCH('/portal/users/{id}/')
  Future<dynamic> updateUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/portal/users/{id}/suspend/')
  Future<dynamic> suspendUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  @POST('/portal/users/{id}/reinstate/')
  Future<dynamic> reinstateUser(
    @Path('id') String userId,
    @Body() Map<String, dynamic> data,
  );

  // --- Shops & products ---
  @GET('/portal/shops/')
  Future<dynamic> getShops({
    @Query('q') String? query,
    @Query('verification_status') String? verificationStatus,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/shops/{handle}/')
  Future<dynamic> getShop(@Path('handle') String handle);

  @PATCH('/portal/shops/{handle}/')
  Future<dynamic> updateShop(
    @Path('handle') String handle,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/products/')
  Future<dynamic> getProducts({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // --- Shop certifications (the review queue) ---
  @GET('/portal/shop-certifications/')
  Future<dynamic> getShopCertifications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/shop-certifications/{id}/')
  Future<dynamic> reviewShopCertification(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Orders ---
  @GET('/portal/orders/')
  Future<dynamic> getOrders({
    @Query('status') String? status,
    @Query('fulfillment_type') String? fulfillmentType,
    @Query('payment_status') String? paymentStatus,
    @Query('payment_method') String? paymentMethod,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/orders/{id}/')
  Future<dynamic> getOrder(@Path('id') String orderId);

  @PATCH('/portal/orders/{id}/status/')
  Future<dynamic> updateOrderStatus(
    @Path('id') String orderId,
    @Body() Map<String, dynamic> data,
  );

  // --- Gyms ---
  @GET('/portal/gyms/')
  Future<dynamic> getGyms({
    @Query('q') String? query,
    @Query('category') String? category,
    @Query('access_type') String? accessType,
    @Query('is_verified') bool? isVerified,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/gyms/{id}/')
  Future<dynamic> updateGym(
    @Path('id') String gymId,
    @Body() Map<String, dynamic> data,
  );

  // --- Communities ---
  @GET('/portal/communities/')
  Future<dynamic> getCommunities({
    @Query('q') String? query,
    @Query('is_public') bool? isPublic,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // --- Stations ---
  @GET('/portal/stations/')
  Future<dynamic> getStations({
    @Query('q') String? query,
    @Query('is_active') bool? isActive,
    @Query('is_primary') bool? isPrimary,
    @Query('owner_type') String? ownerType,
    @Query('city') String? city,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/stations/{id}/')
  Future<dynamic> updateStation(
    @Path('id') String stationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Application review queues ---
  @GET('/portal/station-applications/')
  Future<dynamic> getStationApplications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/station-applications/{id}/')
  Future<dynamic> reviewStationApplication(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/delivery-personnel/')
  Future<dynamic> getDeliveryPersonnel({
    @Query('q') String? query,
    @Query('vehicle_type') String? vehicleType,
    @Query('is_active') bool? isActive,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/delivery-personnel/{id}/')
  Future<dynamic> updateDeliveryPersonnel(
    @Path('id') String personnelId,
    @Body() Map<String, dynamic> data,
  );

  @GET('/portal/delivery-personnel-applications/')
  Future<dynamic> getDeliveryApplications({
    @Query('status') String? status,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PATCH('/portal/delivery-personnel-applications/{id}/')
  Future<dynamic> reviewDeliveryApplication(
    @Path('id') String applicationId,
    @Body() Map<String, dynamic> data,
  );

  // --- Wallet (read-only) ---
  @GET('/portal/transactions/')
  Future<dynamic> getTransactions({
    @Query('status') String? status,
    @Query('transaction_type') String? transactionType,
    @Query('direction') String? direction,
    @Query('email') String? email,
    @Query('q') String? query,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/portal/wallet/reconciliation/')
  Future<dynamic> getReconciliation();
}