import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'verification_repository.g.dart';

@RestApi()
abstract class VerificationRepository {
  factory VerificationRepository(Dio dio, {String baseUrl}) = _VerificationRepository;

  @GET('/verification/documents/')
  Future<Map<String, dynamic>> getDocuments();

  @POST('/verification/documents/')
  Future<Map<String, dynamic>> uploadDocument(@Body() FormData data);

  @GET('/verification/submissions/')
  Future<Map<String, dynamic>> getSubmissions();

  @POST('/verification/submissions/')
  Future<Map<String, dynamic>> createSubmission(@Body() Map<String, dynamic> data);
}
