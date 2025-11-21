import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatbotProvider extends ChangeNotifier {
  final ChatbotService _chatbotService = ChatbotService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Show typing indicator
    _setLoading(true);

    try {
      // Prepare conversation history for context
      final conversationHistory = _messages
          .where((msg) => !msg.isUser)
          .map(
            (msg) => {
              'role': msg.isUser ? 'user' : 'assistant',
              'content': msg.content,
            },
          )
          .toList();

      // Get bot response
      final response = await _chatbotService.sendMessage(
        content,
        conversationHistory,
      );

      // Add bot response
      final botMessage = ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        content:
            "I'm sorry, I'm having trouble connecting right now. Please try again later.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        content:
            "Hello! I'm MenstruAI, your personal menstrual health assistant. I can help you with questions about your cycle, symptoms, and app features. What would you like to know?",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }
}
