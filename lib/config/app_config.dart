import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const int primaryInt = 0xFF0F172A;
  static const int accentInt = 0xFF00FFFF;
  static const int successInt = 0xFF00FF9D;
  static const int dangerInt = 0xFFFF2E63;

  static const Color primary = Color(primaryInt);
  static const Color accent = Color(accentInt);
  static const Color success = Color(successInt);
  static const Color danger = Color(dangerInt);

  static const int maxMessageLength = 100;

  static const String appName = "ATM DASHBOARD";
  static const String appVersion = "1.3.0";

  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000';
  static String get apiToken => dotenv.env['API_TOKEN'] ?? '';
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
}
