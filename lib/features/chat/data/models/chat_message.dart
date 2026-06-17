class ChatMessage {
  final String role;    // "user" | "assistant"
  final String content;

  const ChatMessage({required this.role, required this.content});

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    role: json['role'] as String,
    content: json['content'] as String,
  );
}

class ChatResponse {
  final String answer;
  final String sessionId;

  const ChatResponse({required this.answer, required this.sessionId});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => ChatResponse(
    answer: json['answer'] as String,
    sessionId: json['session_id'] as String,
  );
}
