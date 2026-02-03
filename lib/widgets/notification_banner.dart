import 'package:flutter/material.dart';
import '../config/app_config.dart';

class NotificationBanner extends StatelessWidget {
  final bool show;
  final String message;

  const NotificationBanner({
    super.key,
    required this.show,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      top: show ? 60 : -100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(AppConfig.dangerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
