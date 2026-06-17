import 'package:dio/dio.dart';
import '../models/chat_session.dart';
import '../../../../features/chat/data/models/chat_message.dart';

class SessionsRemoteDataSource {
  final Dio _dio;
  SessionsRemoteDataSource(this._dio);

  Future<List<ChatSession>> getSessions() async {
    final response = await _dio.get('/sessions');
    return (response.data as List)
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final response = await _dio.get('/sessions/$sessionId/messages');
    return (response.data as List)
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete('/sessions/$sessionId');
  }
}
