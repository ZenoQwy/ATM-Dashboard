import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:ui';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ATMDashboard());
}

class ATMDashboard extends StatelessWidget {
  const ATMDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Lexend'),
          bodyMedium: TextStyle(fontFamily: 'Lexend'),
          displayLarge: TextStyle(fontFamily: 'Lexend'),
        ),
      ),
      home: const SkyDashboard(),
    );
  }
}

class SkyDashboard extends StatefulWidget {
  const SkyDashboard({super.key});

  @override
  State<SkyDashboard> createState() => _SkyDashboardState();
}

class _SkyDashboardState extends State<SkyDashboard> {
  bool isMuted = false;
  String? alertMessage;
  bool showNotificationBanner = false;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    initOneSignal();
  }

  void initOneSignal() {
    OneSignal.initialize("9ea4abf1-0eb3-4b17-98e6-bf80e7f9d136");
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
      _triggerInAppNotification(event.notification.body ?? 'Signal détecté');
    });

    setState(() {
      isMuted = !(OneSignal.User.pushSubscription.optedIn ?? true);
    });
  }

  void _triggerInAppNotification(String message) {
    _bannerTimer?.cancel();
    setState(() {
      alertMessage = message;
      showNotificationBanner = true;
    });
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => showNotificationBanner = false);
    });
  }

  void toggleNotifications() {
    if (isMuted) {
      OneSignal.User.pushSubscription.optIn();
      setState(() => isMuted = false);
    } else {
      OneSignal.User.pushSubscription.optOut();
      setState(() => isMuted = true);
    }
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
                const Spacer(),
                _buildMainLogo(),
                const Spacer(),
                _buildDataPanel(),
                const SizedBox(height: 40),
                _buildControlSection(),
                const SizedBox(height: 50),
              ],
            ),
          ),
          _buildNotificationBanner(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -50,
      left: -50,
      child: Container(
        width: 300,
        height: 300,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ATM DASHBOARD",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              Text(
                "Version 1.0",
                style: TextStyle(
                  color: Colors.cyanAccent.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF00FF9D),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0xFF00FF9D), blurRadius: 8, spreadRadius: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMainLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        'assets/images/ATM_Dashboard.png',
        height: MediaQuery.of(context).size.height * 0.35,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDataPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem("TPS", "20.0", const Color(0xFF00FF9D)),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
          _statItem("MSPT", "12.4", Colors.cyanAccent),
        ],
      ),
    );
  }

  Widget _statItem(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -1,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.3),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildControlSection() {
    return GestureDetector(
      onTap: toggleNotifications,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 16),
        decoration: BoxDecoration(
          color: isMuted
              ? Colors.transparent
              : Colors.cyanAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMuted
                ? Colors.white.withOpacity(0.1)
                : Colors.cyanAccent.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMuted
                  ? Icons.notifications_off_outlined
                  : Icons.notifications_active_outlined,
              size: 18,
              color: isMuted ? Colors.white24 : Colors.cyanAccent,
            ),
            const SizedBox(width: 12),
            Text(
              isMuted ? "NOTIFICATIONS : OFF" : "NOTIFICATIONS : ON",
              style: TextStyle(
                color: isMuted ? Colors.white38 : Colors.cyanAccent,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      top: showNotificationBanner ? 50 : -100,
      left: 15,
      right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2E63).withOpacity(0.9),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    alertMessage ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
