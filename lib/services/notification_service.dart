import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/app_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  bool get isMuted => isMutedNotifier.value;

  Function(String)? onNotificationReceived;

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
      onNotificationReceived?.call(event.notification.body ?? 'Signal détecté');
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

  void setNotificationHandler(Function(String) handler) {
    onNotificationReceived = handler;
  }
}
