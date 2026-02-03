import 'package:intl/intl.dart';

class IntrusionLog {
  final String message;
  final DateTime timestamp;

  IntrusionLog({required this.message, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  String get formattedTime => DateFormat('HH:mm:ss').format(timestamp);

  Map<String, dynamic> toJson() {
    return {'message': message, 'timestamp': timestamp.toIso8601String()};
  }

  factory IntrusionLog.fromJson(Map<String, dynamic> json) {
    return IntrusionLog(
      message: json['message'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
