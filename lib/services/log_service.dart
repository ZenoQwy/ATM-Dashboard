import 'package:atm_dashboard/models/intrusion_log.dart';
import 'package:flutter/material.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final ValueNotifier<List<IntrusionLog>> logsNotifier =
      ValueNotifier<List<IntrusionLog>>([]);

  void addLog(String message) {
    final newLog = IntrusionLog(message: message);
    logsNotifier.value = [newLog, ...logsNotifier.value];
  }
}
