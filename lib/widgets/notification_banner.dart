import 'package:flutter/material.dart';
import '../config/app_config.dart';

class NotificationBanner extends StatelessWidget {
  final bool show;
  final String message;
  final String type;
  final VoidCallback onTap;

  const NotificationBanner({
    super.key,
    required this.show,
    required this.message,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIntrusion = type == 'intrusion';

    final accentColor = isIntrusion
        ? const Color(0xFFFF3B30)
        : const Color(0xFF00E5FF);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      top: show ? 55 : -120,
      left: 15,
      right: 15,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIntrusion ? Icons.fmd_bad_rounded : Icons.forum_rounded,
                  color: accentColor,
                  size: 26,
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                height: 35,
                width: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      accentColor.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isIntrusion ? "SÉCURITÉ" : "MESSAGE",
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
