import 'package:flutter/material.dart';
import '../../data/models/chat_session.dart';
import '../../data/repositories/sessions_repository.dart';
import '../../../chat/data/models/chat_message.dart';

class SessionsProvider extends ChangeNotifier {
  final SessionsRepository _repo;
  SessionsProvider(this._repo);

  List<ChatSession> _sessions = [];
  List<ChatMessage> _sessionMessages = [];
  bool _loading = false;
  bool _messagesLoading = false;
  String? _error;

  List<ChatSession> get sessions => _sessions;
  List<ChatMessage> get sessionMessages => _sessionMessages;
  bool get loading => _loading;
  bool get messagesLoading => _messagesLoading;
  String? get error => _error;

  Future<void> loadSessions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _sessions = await _repo.getSessions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSessionMessages(String sessionId) async {
    _messagesLoading = true;
    _sessionMessages = [];
    notifyListeners();
    try {
      _sessionMessages = await _repo.getMessages(sessionId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _messagesLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repo.deleteSession(sessionId);
      _sessions.removeWhere((s) => s.id == sessionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
