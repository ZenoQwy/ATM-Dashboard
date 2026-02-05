import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _socketService.chatMessagesNotifier.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _socketService.sendMessage(text);
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _socketService.chatMessagesNotifier,
              builder: (context, messages, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final bool isMe = m['user'] == "DASHBOARD";

                    final bool isSameAsPrevious =
                        index > 0 && messages[index - 1]['user'] == m['user'];

                    return _buildModernBubble(
                      m['user'] ?? 'Inconnu',
                      m['msg'] ?? '',
                      m['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                      isMe,
                      isSameAsPrevious,
                    );
                  },
                );
              },
            ),
          ),

          _buildModernInput(),
        ],
      ),
    );
  }

  Widget _buildModernBubble(
    String user,
    String text,
    int ts,
    bool isMe,
    bool isGrouped,
  ) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(ts);

    return Padding(
      padding: EdgeInsets.only(top: isGrouped ? 2 : 12),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isGrouped)
            Padding(
              padding: const EdgeInsets.only(left: 35, right: 35, bottom: 4),
              child: Text(
                user,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isMe
                      ? Colors.cyanAccent.withOpacity(0.7)
                      : Colors.white54,
                ),
              ),
            ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) _buildMiniAvatar(user),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.cyanAccent.withOpacity(0.15)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: Border.all(
                      color: isMe
                          ? Colors.cyanAccent.withOpacity(0.3)
                          : Colors.white12,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(time),
                        style: TextStyle(
                          fontSize: 9,
                          color: isMe
                              ? Colors.cyanAccent.withOpacity(0.7)
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isMe) _buildMiniAvatar("DASHBOARD"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String user) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: user == "DASHBOARD"
            ? Image.asset("assets/images/ATM_Dashboard.png", fit: BoxFit.cover)
            : Image.network("https://minotar.net/avatar/$user/32.png"),
      ),
    );
  }

  Widget _buildModernInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _chatController,
            builder: (context, value, child) {
              final length = value.text.length;
              final progress = length / AppConfig.maxMessageLength;
              final bool isFull = progress >= 1;
              final Color activeColor = isFull
                  ? AppConfig.danger
                  : AppConfig.accent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            activeColor,
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$length / ${AppConfig.maxMessageLength}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isFull ? AppConfig.danger : Colors.white38,
                        fontWeight: isFull
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    controller: _chatController,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                        AppConfig.maxMessageLength,
                      ),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9\s.,!?;:@()#&"\-+/*=%€$À-ÿ]'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      hintText: "Écrire un message...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _chatController,
                builder: (context, value, child) {
                  final bool isEmpty = value.text.trim().isEmpty;
                  final Color btnColor = isEmpty
                      ? Colors.white10
                      : AppConfig.accent;

                  return GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: btnColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (!isEmpty)
                            BoxShadow(
                              color: btnColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: isEmpty
                            ? Colors.white24
                            : const Color(0xFF0D1117),
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _socketService.chatMessagesNotifier.removeListener(_scrollToBottom);
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
