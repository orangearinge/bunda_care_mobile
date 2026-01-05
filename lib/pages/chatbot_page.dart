import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../models/api_error.dart';

/// Halaman Chatbot Gizi dengan integrasi RAG
/// Respons bersifat temporary dan tidak disimpan ke database
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  
  // List of messages (temporary, tidak disimpan ke database)
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan welcome message
    _messages.add(ChatMessage.bot(
      'Halo Bunda! 👋\n\nSaya Bunda Care AI Assistant, siap membantu menjawab pertanyaan seputar kesehatan ibu dan anak.\n\nSilakan tanyakan tentang:\n• Nutrisi kehamilan\n• ASI dan menyusui\n• MPASI\n• Menu harian\n• Dan topik kesehatan lainnya',
    ));
  }

  /// Kirim pesan ke RAG chatbot
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    if (text.isEmpty) return;

    // Tambahkan user message
    setState(() {
      _messages.add(ChatMessage.user(text));
      _isLoading = true;
    });

    // Clear input
    _messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Kirim ke RAG API
      final response = await _chatService.sendQuery(text);
      
      // Tambahkan bot response
      setState(() {
        _messages.add(ChatMessage.bot(response['answer']));
        _isLoading = false;
      });

      // Scroll to bottom lagi setelah dapat response
      _scrollToBottom();
    } on ApiError catch (e) {
      setState(() {
        _messages.add(ChatMessage.bot(
          '❌ Maaf, terjadi kesalahan: ${e.message}\n\nSilakan coba lagi.',
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage.bot(
          '❌ Terjadi kesalahan yang tidak terduga.\n\nSilakan coba lagi.',
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  /// Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Gizi'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink[400]!, Colors.pink[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ℹ️ Informasi'),
                  content: const Text(
                    'Chat ini menggunakan RAG (Retrieval-Augmented Generation) untuk memberikan informasi akurat tentang kesehatan ibu dan anak.\n\n'
                    '⚠️ Chat bersifat temporary dan tidak disimpan ke database.\n\n'
                    'Selalu konsultasikan dengan tenaga kesehatan profesional untuk keputusan medis.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingBubble();
                      }
                      
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Divider
          const Divider(height: 1),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Build empty state (tidak digunakan karena ada welcome message)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.pink[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.pink[200],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chat Konsultasi Gizi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tanyakan seputar nutrisi kehamilan,\nASI, MPASI, dan menu harian',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(
                        colors: [Colors.pink[300]!, Colors.pink[200]!],
                      )
                    : null,
                color: message.isUser ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                message.formattedTime,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading bubble
  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[300]!),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Bunda Care sedang berpikir...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build input area
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ketik pertanyaan...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isLoading,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink[300]!, Colors.pink[200]!],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink[200]!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
