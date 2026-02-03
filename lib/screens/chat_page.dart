import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../services/socket_service.dart';
import '../config/app_config.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatController = TextEditingController();
  final _scrollController = ScrollController();
  final _socketService = SocketService();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _socketService.setMessageHandler(_onMessageReceived);
  }

  void _onMessageReceived(ChatMessage message) {
    if (mounted) {
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _socketService.sendMessage(text, 'Dashboard');

    setState(() {
      _messages.add(ChatMessage(user: 'Dashboard', message: text, isMe: true));
    });

    _chatController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(15),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final String time =
        "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe
              ? Colors.cyanAccent.withOpacity(0.15)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(message.isMe ? 15 : 0),
            bottomRight: Radius.circular(message.isMe ? 0 : 15),
          ),
          border: Border.all(
            color: message.isMe
                ? Colors.cyanAccent.withOpacity(0.3)
                : Colors.white10,
          ),
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message.user.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _chatController,
            builder: (context, value, child) {
              final length = value.text.length;
              final isOverLimit = length > AppConfig.maxMessageLength;

              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '$length / ${AppConfig.maxMessageLength} caractères',
                  style: TextStyle(
                    fontSize: 10,
                    color: isOverLimit ? Colors.orange : Colors.white38,
                    fontWeight: isOverLimit
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      AppConfig.maxMessageLength,
                    ),
                  ],
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.cyanAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
