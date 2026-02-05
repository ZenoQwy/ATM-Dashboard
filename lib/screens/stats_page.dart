import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../widgets/stat_item.dart';
import '../services/notification_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/ATM_Dashboard.png', height: 180),
        const SizedBox(height: 40),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatItem(label: "TPS", value: "20.0", color: AppConfig.success),
            StatItem(label: "MSPT", value: "12.4", color: Colors.cyanAccent),
          ],
        ),
        const SizedBox(height: 50),
        _buildNotificationToggle(),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: _notificationService.isMutedNotifier,
      builder: (context, isMuted, child) {
        return GestureDetector(
          onTap: () => _notificationService.toggleMute(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isMuted
                    ? Colors.white10
                    : Colors.cyanAccent.withOpacity(0.3),
              ),
            ),
            child: Text(
              isMuted ? "NOTIFICATIONS : OFF" : "NOTIFICATIONS : ON",
              style: TextStyle(
                color: isMuted ? Colors.white24 : Colors.cyanAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
