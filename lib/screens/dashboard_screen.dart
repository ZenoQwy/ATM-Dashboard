import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../config/app_config.dart';
import '../models/intrusion_log.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../widgets/notification_banner.dart';
import 'stats_page.dart';
import 'chat_page.dart';
import 'logs_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _alertMessage = '';
  bool _showNotificationBanner = false;
  Timer? _bannerTimer;

  final List<IntrusionLog> _intrusionLogs = [];
  final _notificationService = NotificationService();
  final _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();

    _notificationService.setNotificationHandler(_handleNewAlert);
    _socketService.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  void _handleNewAlert(String message) {
    setState(() {
      _alertMessage = message;
      _showNotificationBanner = true;
      _intrusionLogs.insert(0, IntrusionLog(message: message));
    });

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showNotificationBanner = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      StatsPage(),
                      ChatPage(),
                      LogsPage(logs: _intrusionLogs),
                    ],
                  ),
                ),
              ],
            ),
          ),
          NotificationBanner(
            show: _showNotificationBanner,
            message: _alertMessage,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                "Version ${AppConfig.appVersion}",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildLiveIndicator(),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(AppConfig.successColor),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(AppConfig.successColor), blurRadius: 8),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(AppConfig.primaryColor),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: "STATS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "CHAT",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: "LOGS",
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}
