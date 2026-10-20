import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'activity_repository.g.dart';

@RestApi()
abstract class ActivityRepository {
  factory ActivityRepository(Dio dio, {String baseUrl}) = _ActivityRepository;

  @GET('/auth/activity-log/')
  Future<dynamic> getActivityLog({@Query('type') String? type});
}
