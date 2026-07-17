import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const SmartGuardianApp());
}

class SmartGuardianApp extends StatelessWidget {
  const SmartGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Guardian',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  bool isSystemSecure = true;
  String alertMessage = "Normal network behavior.";
  bool isLoading = false;

  // Mock data for devices
  final List<Map<String, dynamic>> devices = [
    {"name": "Living Room Camera", "type": "Camera", "isSecure": true, "ip": "192.168.1.15"},
    {"name": "Main Door Lock", "type": "Lock", "isSecure": true, "ip": "192.168.1.20"},
    {"name": "Smart TV", "type": "TV", "isSecure": true, "ip": "192.168.1.45"},
  ];

  // متد ارتباط با سرور پایتون
  Future<void> fetchSecurityStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      // فراخوانی سرور فلسک پایتون
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/status'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          isSystemSecure = data['is_secure'];
          alertMessage = data['message'];
          // اعمال وضعیت خطر روی دوربین در صورت بروز آنومالی
          devices[0]['isSecure'] = isSystemSecure;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        alertMessage = "Error connecting to backend server!";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // در ابتدای بالا آمدن برنامه، یک بار وضعیت را چک میکند
    fetchSecurityStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Guardian 🛡️'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1D1E33),
      ),
      body: Column(
        children: [
          // 1. Security Status Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSystemSecure
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSystemSecure ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else ...[
                  Icon(
                    isSystemSecure ? Icons.shield : Icons.gpp_bad,
                    size: 64,
                    color: isSystemSecure ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSystemSecure ? "SYSTEM SECURE" : "SECURITY ALERT: SUSPICIOUS ACTIVITY",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isSystemSecure ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Critical Alert Banner from Python Backend
          if (!isSystemSecure)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CRITICAL WARNING (LIVE):",
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alertMessage,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 3. Connected Devices Title
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Connected Devices",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 4. Dynamic Devices List
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: const Color(0xFF1D1E33),
                  child: ListTile(
                    leading: Icon(
                      device['type'] == 'Camera'
                          ? Icons.videocam
                          : device['type'] == 'Lock'
                          ? Icons.lock
                          : Icons.tv,
                      color: Colors.blueAccent,
                    ),
                    title: Text(device['name']),
                    subtitle: Text("IP: ${device['ip']}"),
                    trailing: Icon(
                      device['isSecure'] ? Icons.check_circle : Icons.warning,
                      color: device['isSecure'] ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ),

          // 5. Fetch Live Data Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: fetchSecurityStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Network Status (Live)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}