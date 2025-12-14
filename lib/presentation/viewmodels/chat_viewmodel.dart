import 'package:agros/core/services/ai_service.dart';
import 'package:agros/data/models/chat_message.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final AiService _aiService = AiService();

  final List<ChatMessage> _messages = [];
  bool _isAiTyping = false;

  List<ChatMessage> get messages => _messages;
  bool get isAiTyping => _isAiTyping;

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    _addMessage(text, true);
    
    _isAiTyping = true;
    notifyListeners();

    try {
      final responseText = await _aiService.sendMessage(text);
      
      _addMessage(responseText, false);
    } catch (e) {
      _addMessage("Maaf, terjadi kesalahan: $e", false, isError: true);
    } finally {
      _isAiTyping = false;
      notifyListeners();
    }
  }

  void _addMessage(String text, bool isUser, {bool isError = false}) {
    _messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
      isError: isError,
    ));
    notifyListeners();
  }
}
