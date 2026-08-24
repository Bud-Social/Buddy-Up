import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'wallet_repository.g.dart';

@RestApi()
abstract class WalletRepository {
  factory WalletRepository(Dio dio, {String baseUrl}) = _WalletRepository;

  @GET('/wallet/balance/')
  Future<dynamic> getBalance();

  @GET('/wallet/transactions/')
  Future<dynamic> getTransactions({
    @Query('type') String? type,
    @Query('direction') String? direction,
    @Query('cursor') String? cursor,
  });

  @POST('/wallet/purchase/initialize/')
  Future<dynamic> initializePurchase(
    @Body() Map<String, dynamic> data,
  );

  @POST('/wallet/purchase/confirm/')
  Future<dynamic> confirmPurchase(
    @Body() Map<String, dynamic> data,
  );

  @POST('/wallet/tip/')
  Future<void> tip(@Body() Map<String, dynamic> data);

  @POST('/wallet/gift/')
  Future<void> gift(@Body() Map<String, dynamic> data);

  @POST('/wallet/withdraw/')
  Future<dynamic> withdraw(@Body() Map<String, dynamic> data);

  @GET('/wallet/withdraw/banks/')
  Future<dynamic> getBanks({@Query('country') String? country});

  @POST('/wallet/withdraw/bank-resolve/')
  Future<dynamic> resolveBank(@Body() Map<String, dynamic> data);

  @GET('/wallet/bundles/')
  Future<dynamic> getBundles();

  @GET('/wallet/exchange-rates/')
  Future<dynamic> getExchangeRates();

  @POST('/wallet/creator/transfer/')
  Future<dynamic> transferFromCreator(@Body() Map<String, dynamic> data);

  @PATCH('/wallet/creator/profile/')
  Future<dynamic> updateCreatorProfile(@Body() Map<String, dynamic> data);

  @POST('/wallet/payout-request/')
  Future<dynamic> requestPayout(@Body() Map<String, dynamic> data);

  @GET('/wallet/payout-history/')
  Future<dynamic> getPayoutHistory();
}
