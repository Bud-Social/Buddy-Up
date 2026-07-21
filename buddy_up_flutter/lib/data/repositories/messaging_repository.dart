import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'messaging_repository.g.dart';

@RestApi()
abstract class MessagingRepository {
  factory MessagingRepository(Dio dio, {String baseUrl}) = _MessagingRepository;

  @GET('/messaging/conversations/')
  Future<Map<String, dynamic>> getConversations();

  @POST('/messaging/conversations/start/')
  Future<Map<String, dynamic>> startConversation(@Body() Map<String, dynamic> body);

  @GET('/messaging/conversations/{id}/')
  Future<Map<String, dynamic>> getConversation(@Path('id') String conversationId);

  @GET('/messaging/conversations/{id}/messages/')
  Future<Map<String, dynamic>> getMessages(
    @Path('id') String conversationId, {
    @Query('before') String? before,
    @Query('attachment_type') String? attachmentType,
  });

  @POST('/messaging/conversations/{id}/messages/')
  Future<Map<String, dynamic>> sendMessage(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/conversations/{id}/read/')
  Future<Map<String, dynamic>> markRead(@Path('id') String conversationId);

  @POST('/messaging/messages/{mid}/react/')
  Future<Map<String, dynamic>> reactToMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/messaging/messages/{mid}/delete/')
  Future<void> deleteMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/upload/')
  @MultiPart()
  Future<Map<String, dynamic>> uploadAttachment(@Part() Map<String, dynamic> file);

  @GET('/messaging/conversations/{id}/calls/')
  Future<Map<String, dynamic>> getCallLogs(@Path('id') String conversationId);

  @POST('/messaging/conversations/{id}/calls/')
  Future<Map<String, dynamic>> logCall(
    @Path('id') String conversationId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/messages/{mid}/forward/')
  Future<Map<String, dynamic>> forwardMessage(
    @Path('mid') String messageId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/messaging/link-preview/')
  Future<Map<String, dynamic>> getLinkPreview(@Body() Map<String, dynamic> body);
}
