import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'moderation_repository.g.dart';

/// User-facing moderation entry points (reports only — the staff console has
/// its own repository).
@RestApi()
abstract class ModerationRepository {
  factory ModerationRepository(Dio dio, {String baseUrl}) = _ModerationRepository;

  @POST('/moderation/reports/')
  Future<dynamic> createReport(@Body() Map<String, dynamic> body);
}
