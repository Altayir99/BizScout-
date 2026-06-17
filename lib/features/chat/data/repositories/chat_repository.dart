import '../models/chat_message.dart';
import '../sources/chat_remote_data_source.dart';

class ChatRepository {
  final ChatRemoteDataSource _source;
  ChatRepository(this._source);

  Future<ChatResponse> sendMessage(String message, String? sessionId) =>
      _source.sendMessage(message, sessionId);
}
