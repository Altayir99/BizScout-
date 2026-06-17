import 'package:dio/dio.dart';
import '../models/chat_message.dart';

class ChatRemoteDataSource {
  final Dio _dio;
  ChatRemoteDataSource(this._dio);

  Future<ChatResponse> sendMessage(String message, String? sessionId) async {
    final response = await _dio.post('/chat', data: {
      'message': message,
      if (sessionId != null) 'session_id': sessionId,
    });
    return ChatResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
