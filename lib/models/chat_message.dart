/// Model untuk chat message
/// Digunakan hanya untuk tampilan UI, tidak disimpan ke database
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a user message
  factory ChatMessage.user(String text) {
    return ChatMessage(text: text, isUser: true, isLoading: false);
  }

  /// Create a bot message
  factory ChatMessage.bot(String text) {
    return ChatMessage(text: text, isUser: false, isLoading: false);
  }

  /// Create a loading placeholder message
  factory ChatMessage.loading() {
    return ChatMessage(text: '...', isUser: false, isLoading: true);
  }

  /// Format timestamp untuk display
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
