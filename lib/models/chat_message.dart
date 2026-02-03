class ChatMessage {
  final String user;
  final String message;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.user,
    required this.message,
    required this.isMe,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'msg': message,
      'isMe': isMe,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      user: json['user'] as String,
      message: json['msg'] as String,
      isMe: json['isMe'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
