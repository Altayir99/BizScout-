import '../models/chat_session.dart';
import '../sources/sessions_remote_data_source.dart';
import '../../../../features/chat/data/models/chat_message.dart';

class SessionsRepository {
  final SessionsRemoteDataSource _source;
  SessionsRepository(this._source);

  Future<List<ChatSession>> getSessions() => _source.getSessions();
  Future<List<ChatMessage>> getMessages(String id) => _source.getMessages(id);
  Future<void> deleteSession(String id) => _source.deleteSession(id);
}
