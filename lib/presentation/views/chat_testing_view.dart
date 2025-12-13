import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:agros/presentation/viewmodels/chat_viewmodel.dart';
import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';
import 'package:agros/data/models/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _lastProcessedSttText = "";

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    
    context.read<ChatViewModel>().sendUserMessage(text);
    
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agros"),
        centerTitle: true,
        backgroundColor: colorScheme.surfaceContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, chatVM, child) {
                if (chatVM.messages.isEmpty) {
                  return Center(
                    child: Text(
                      "Halo! Saya Agros.\nSilakan tanya tentang pertanian.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatVM.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatVM.messages[index];
                    return _ChatBubble(message: msg);
                  },
                );
              },
            ),
          ),

          // 2. LOADING INDICATOR
          Consumer<ChatViewModel>(
            builder: (context, chatVM, child) {
              if (chatVM.isAiTyping) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Agros sedang mengetik...",
                      style: TextStyle(
                        fontSize: 12, 
                        fontStyle: FontStyle.italic,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 3. INPUT AREA (BRIDGE STT -> CHAT)
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SttViewmodel>(
      builder: (context, sttVM, child) {
        
        // --- LOGIC BRIDGE (STT ke Chat) ---
        // Jika ada input final dari suara, dan belum pernah diproses
        if (sttVM.finalInput.isNotEmpty && 
            sttVM.finalInput != _lastProcessedSttText && 
            !sttVM.isListening) {
          
          // Simpan agar tidak loop
          _lastProcessedSttText = sttVM.finalInput;

          // Jalankan pengiriman pesan secara otomatis
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleSend(sttVM.finalInput);
            
            // Opsional: Masukkan teks ke textfield biar user lihat
            // _textController.text = sttVM.finalInput;
          });
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              // TOMBOL MIC (Integrasi STT)
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: sttVM.isListening 
                      ? colorScheme.error // Merah kalau listening
                      : colorScheme.primaryContainer,
                  foregroundColor: sttVM.isListening
                      ? colorScheme.onError
                      : colorScheme.onPrimaryContainer,
                ),
                icon: Icon(sttVM.isListening ? Icons.stop : Icons.mic),
                onPressed: sttVM.toggleListening,
              ),

              const SizedBox(width: 10),

              // TEXT FIELD
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: sttVM.isListening ? "Mendengarkan..." : "Tanya Agros...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (val) => _handleSend(val),
                ),
              ),

              const SizedBox(width: 8),

              // TOMBOL KIRIM
              IconButton(
                icon: const Icon(Icons.send),
                color: colorScheme.primary,
                onPressed: () => _handleSend(_textController.text),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}