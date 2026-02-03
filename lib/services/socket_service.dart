import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';
import '../models/chat_message.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  Function(ChatMessage)? onMessageReceived;

  void initialize() {
    socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket.on('mc_chat_message', _handleIncomingMessage);
  }

  void _handleIncomingMessage(dynamic data) {
    if (onMessageReceived != null) {
      final message = ChatMessage(
        user: data['user'] as String,
        message: data['msg'] as String,
        isMe: false,
      );
      onMessageReceived!(message);
    }
  }

  void sendMessage(String text, String username) {
    String truncatedText = text;
    if (text.length > AppConfig.maxMessageLength) {
      truncatedText = '${text.substring(0, AppConfig.maxMessageLength - 3)}...';
    }

    socket.emit('send_to_mc', {'text': truncatedText});
  }

  void setMessageHandler(Function(ChatMessage) handler) {
    onMessageReceived = handler;
  }

  void dispose() {
    socket.dispose();
  }
}
