import 'package:flutter/material.dart';
import '../models/api_error.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

enum ChatStatus { initial, loading, success, error }

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  ChatStatus _status = ChatStatus.initial;
  final List<ChatMessage> _messages = [];
  String? _errorMessage;

  ChatStatus get status => _status;
  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ChatStatus.loading;

  ChatProvider() {
    // Add welcome message on initialization
    _messages.add(ChatMessage.bot(
      'Halo Bunda! 👋\n\nSaya Bunda Care AI Assistant, siap membantu menjawab pertanyaan seputar kesehatan ibu dan anak.\n\nSilakan tanyakan tentang:\n• Nutrisi kehamilan\n• ASI dan menyusui\n• MPASI\n• Menu harian\n• Dan topik kesehatan lainnya',
    ));
  }

  /// Send query to RAG chatbot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage.user(text));
    _status = ChatStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _chatService.sendQuery(text);
      
      // Add bot response
      _messages.add(ChatMessage.bot(response['answer']));
      _status = ChatStatus.success;
      notifyListeners();
    } on ApiError catch (e) {
      _messages.add(ChatMessage.bot(
        '❌ Maaf, terjadi kesalahan: ${e.message}\n\nSilakan coba lagi.',
      ));
      _status = ChatStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _messages.add(ChatMessage.bot(
        '❌ Terjadi kesalahan yang tidak terduga.\n\nSilakan coba lagi.',
      ));
      _status = ChatStatus.error;
      _errorMessage = 'Terjadi kesalahan yang tidak terduga';
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage.bot(
      'Halo Bunda! 👋\n\nSaya Bunda Care AI Assistant, siap membantu menjawab pertanyaan seputar kesehatan ibu dan anak.\n\nSilakan tanyakan tentang:\n• Nutrisi kehamilan\n• ASI dan menyusui\n• MPASI\n• Menu harian\n• Dan topik kesehatan lainnya',
    ));
    notifyListeners();
  }
}
