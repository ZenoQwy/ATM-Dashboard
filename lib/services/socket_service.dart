import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  IO.Socket? socket;

  final ValueNotifier<List<String>> onlinePlayersNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> chatMessagesNotifier =
      ValueNotifier([]);

  void initialize() {
    socket = IO.io(
      'https://atm-api-6ob5.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket!.on('chat_history', (data) {
      chatMessagesNotifier.value = List<Map<String, dynamic>>.from(data);
    });

    socket!.on('player_list_update', (data) {
      onlinePlayersNotifier.value = List<String>.from(data);
    });

    socket!.on('mc_chat_message', (data) {
      final current = List<Map<String, dynamic>>.from(
        chatMessagesNotifier.value,
      );
      current.add(Map<String, dynamic>.from(data));
      chatMessagesNotifier.value = current;
    });
  }

  void sendMessage(String text) {
    if (socket != null && socket!.connected) {
      socket!.emit('send_to_mc', {'text': text});
    }
  }

  void dispose() {
    socket?.dispose();
  }
}
