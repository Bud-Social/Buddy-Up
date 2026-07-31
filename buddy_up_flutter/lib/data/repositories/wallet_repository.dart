import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'wallet_repository.g.dart';

@RestApi()
abstract class WalletRepository {
  factory WalletRepository(Dio dio, {String baseUrl}) = _WalletRepository;

  @GET('/wallet/balance/')
  Future<Map<String, dynamic>> getBalance();

  @GET('/wallet/transactions/')
  Future<Map<String, dynamic>> getTransactions({
    @Query('type') String? type,
    @Query('direction') String? direction,
    @Query('cursor') String? cursor,
  });

  @POST('/wallet/purchase/initialize/')
  Future<Map<String, dynamic>> initializePurchase(
    @Body() Map<String, dynamic> data,
  );

  @POST('/wallet/purchase/confirm/')
  Future<Map<String, dynamic>> confirmPurchase(
    @Body() Map<String, dynamic> data,
  );

  @POST('/wallet/tip/')
  Future<void> tip(@Body() Map<String, dynamic> data);

  @POST('/wallet/gift/')
  Future<void> gift(@Body() Map<String, dynamic> data);

  @POST('/wallet/withdraw/')
  Future<Map<String, dynamic>> withdraw(@Body() Map<String, dynamic> data);

  @GET('/wallet/withdraw/banks/')
  Future<Map<String, dynamic>> getBanks({@Query('country') String? country});

  @POST('/wallet/withdraw/bank-resolve/')
  Future<Map<String, dynamic>> resolveBank(@Body() Map<String, dynamic> data);

  @GET('/wallet/bundles/')
  Future<Map<String, dynamic>> getBundles();

  @GET('/wallet/exchange-rates/')
  Future<Map<String, dynamic>> getExchangeRates();

  @POST('/wallet/creator/transfer/')
  Future<Map<String, dynamic>> transferFromCreator(@Body() Map<String, dynamic> data);

  @PATCH('/wallet/creator/profile/')
  Future<Map<String, dynamic>> updateCreatorProfile(@Body() Map<String, dynamic> data);
}
