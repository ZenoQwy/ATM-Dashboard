import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;

  final ValueNotifier<List<String>> onlinePlayersNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> chatMessagesNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  Future<void> wakeServer() async {
    try {
      await http
          .get(Uri.parse('${AppConfig.apiUrl}/wake'))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Wake error: $e');
    }
  }

  void initialize() async {
    await wakeServer();
    await Future.delayed(const Duration(milliseconds: 500));

    socket = IO.io(
      AppConfig.apiUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .enableReconnection()
          .build(),
    );

    socket!.onConnect((_) {
      isConnectedNotifier.value = true;
      debugPrint('Socket connected');
    });

    socket!.onDisconnect((_) {
      isConnectedNotifier.value = false;
      debugPrint('Socket disconnected');
    });

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

  Future<void> sendMessage(String text) async {
    if (socket == null || !socket!.connected) {
      await wakeServer();
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (socket != null && socket!.connected) {
      socket!.emit('send_to_mc', {'text': text});
    } else {
      try {
        await http.post(
          Uri.parse('${AppConfig.apiUrl}/send-message'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': AppConfig.apiToken,
          },
          body: json.encode({'message': text}),
        );
      } catch (e) {
        debugPrint('Send message error: $e');
      }
    }
  }

  void dispose() {
    socket?.dispose();
  }
}
