import 'package:flutter/material.dart';
import '../../data/models/chat_message.dart';
import '../../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repo;
  ChatProvider(this._repo);

  final List<ChatMessage> messages = [];
  String? currentSessionId;
  bool isTyping = false;
  String? error;

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(role: 'user', content: text.trim()));
    isTyping = true;
    error = null;
    notifyListeners();

    try {
      final response = await _repo.sendMessage(text.trim(), currentSessionId);
      currentSessionId = response.sessionId;
      messages.add(ChatMessage(role: 'assistant', content: response.answer));
    } catch (e) {
      error = 'Fehler beim Senden. Bitte versuche es erneut.';
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  void newChat() {
    messages.clear();
    currentSessionId = null;
    error = null;
    notifyListeners();
  }

  void loadSession(String sessionId, List<ChatMessage> history) {
    messages.clear();
    messages.addAll(history);
    currentSessionId = sessionId;
    notifyListeners();
  }

  /// Called from SessionsPage to resume a past conversation in the Chat tab.
  void resumeSession(String sessionId, List<ChatMessage> history) {
    loadSession(sessionId, history);
  }
}
