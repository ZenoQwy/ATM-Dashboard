import 'package:flutter/material.dart';
import '../models/intrusion_log.dart';
import '../services/log_service.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logService = LogService();

    return ValueListenableBuilder<List<IntrusionLog>>(
      valueListenable: logService.logsNotifier,
      builder: (context, logs, child) {
        if (logs.isEmpty) {
          return const Center(
            child: Text(
              'Aucun log pour le moment',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(log);
          },
        );
      },
    );
  }

  Widget _buildLogItem(IntrusionLog log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(
            log.formattedTime,
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(log.message, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
