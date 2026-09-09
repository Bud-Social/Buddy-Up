import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'guardian_repository.g.dart';

@RestApi()
abstract class GuardianRepository {
  factory GuardianRepository(Dio dio, {String baseUrl}) = _GuardianRepository;

  @POST('/guardians/invite/')
  Future<dynamic> inviteTeen(@Body() Map<String, dynamic> body);

  @GET('/guardians/links/')
  Future<dynamic> getLinks();

  @POST('/guardians/links/{id}/accept/')
  Future<void> acceptLink(@Path('id') int linkId);

  @DELETE('/guardians/links/{id}/')
  Future<void> deleteLink(@Path('id') int linkId);

  @PATCH('/guardians/links/{id}/permissions/')
  Future<void> updatePermissions(
    @Path('id') int linkId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/guardians/dashboard/')
  Future<dynamic> getGuardianDashboard();

  @POST('/guardians/accept-invite/')
  Future<dynamic> acceptGuardianInvite(@Body() Map<String, dynamic> body);
}
