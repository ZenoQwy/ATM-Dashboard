import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../config/app_config.dart';
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
  String _alertType = 'chat';

  final _notificationService = NotificationService();
  final _socketService = SocketService();
  bool _isSocketLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    _notificationService.setNotificationHandler(_handleNewAlert);

    _socketService.initialize();

    _socketService.onlinePlayersNotifier.addListener(() {
      if (mounted && !_isSocketLoaded) {
        setState(() => _isSocketLoaded = true);
      }
    });
  }

  void _handleNewAlert(String message, String type) {
    if (type == 'chat' && _selectedIndex == 1) return;
    if (type == 'intrusion' && _selectedIndex == 2) return;

    setState(() {
      _alertMessage = message;
      _alertType = type;
      _showNotificationBanner = true;
    });

    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showNotificationBanner = false);
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
                _buildOnlinePlayersBar(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [StatsPage(), ChatPage(), LogsPage()],
                  ),
                ),
              ],
            ),
          ),
          NotificationBanner(
            show: _showNotificationBanner,
            message: _alertMessage,
            type: _alertType,
            onTap: () {
              setState(() {
                _showNotificationBanner = false;
                _selectedIndex = _alertType == 'intrusion' ? 2 : 1;
              });
            },
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

  Widget _buildOnlinePlayersBar() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _socketService.onlinePlayersNotifier,
      builder: (context, players, _) {
        return SizedBox(height: 80, child: _buildContent(players));
      },
    );
  }

  Widget _buildContent(List<String> players) {
    if (!_isSocketLoaded) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 10,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => _buildSkeletonItem(),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: players.isEmpty
          ? Center(
              key: const ValueKey('empty'),
              child: Text(
                "AUCUN JOUEUR EN LIGNE",
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.accent,
                ),
              ),
            )
          : ListView.builder(
              key: const ValueKey('list'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final name = players[index];
                return TweenAnimationBuilder(
                  key: ValueKey(name),
                  duration: const Duration(milliseconds: 100),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(scale: value, child: child),
                    );
                  },
                  child: _buildPlayerItem(name),
                );
              },
            ),
    );
  }

  Widget _buildSkeletonItem() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.2, end: 0.5),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Container(
            width: 45,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 25,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerItem(String name) {
    return Container(
      width: 45,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.cyanAccent.withOpacity(0.1),
            backgroundImage: NetworkImage(
              "https://minotar.net/helm/$name/64.png",
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppConfig.success,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppConfig.success, blurRadius: 8)],
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
        backgroundColor: AppConfig.primary,
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
