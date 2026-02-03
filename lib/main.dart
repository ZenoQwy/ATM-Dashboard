import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() => runApp(const ATMDashboard());

class ATMDashboard extends StatelessWidget {
  const ATMDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: const SkyHome(),
    );
  }
}

class SkyHome extends StatefulWidget {
  const SkyHome({super.key});

  @override
  State<SkyHome> createState() => _SkyHomeState();
}

class _SkyHomeState extends State<SkyHome> {
  @override
  void initState() {
    super.initState();
    // Debug activé pour voir les erreurs de connexion
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("9ea4abf1-0eb3-4b17-98e6-bf80e7f9d136");
    OneSignal.Notifications.requestPermission(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dégradé inspiré de ton screenshot ATM10
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF74B9FF), Color(0xFFE1F5FE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _statCard(
                      "STATUT SERVEUR",
                      "OPÉRATIONNEL",
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(height: 15),
                    _statCard("TPS ACTUEL", "20.0", Icons.speed, Colors.orange),
                    const SizedBox(height: 30),
                    const Text(
                      "LOGS DE SÉCURITÉ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _alertItem("Intrusion évitée", "10:45"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_queue, size: 40, color: Colors.white),
          SizedBox(width: 15),
          Text(
            "ATM DASHBOARD",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String val, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: col, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                val,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: col,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertItem(String title, String time) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.redAccent),
        title: Text(title),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }
}
