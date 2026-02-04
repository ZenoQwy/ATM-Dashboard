import 'package:atm_dashboard/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/app_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  bool get isMuted => isMutedNotifier.value;

  Function(String message, String type)? onNotificationReceived;

  final _logService = LogService();

  Future<void> initialize() async {
    OneSignal.initialize(AppConfig.oneSignalAppId);
    await OneSignal.Notifications.requestPermission(true);
    await Future.delayed(const Duration(milliseconds: 500));

    final subscription = OneSignal.User.pushSubscription;
    isMutedNotifier.value = !(subscription.optedIn ?? true);

    subscription.addObserver((state) {
      isMutedNotifier.value = !(state.current.optedIn == true);
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();

      final notification = event.notification;
      final message = notification.body ?? 'Signal détecté';
      final data = notification.additionalData;

      final String type = (data?['type'] as String?) ?? 'chat';
      if (type == 'intrusion') {
        _logService.addLog(message);
      }

      onNotificationReceived?.call(message, type);
    });
  }

  void toggleMute() {
    bool newState = !isMutedNotifier.value;
    isMutedNotifier.value = newState;

    if (newState) {
      OneSignal.User.pushSubscription.optOut();
    } else {
      OneSignal.User.pushSubscription.optIn();
    }
  }

  void setNotificationHandler(Function(String, String) handler) {
    onNotificationReceived = handler;
  }
}
