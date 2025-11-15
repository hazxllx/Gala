import 'package:flutter/material.dart';

/// Admin-only Settings screen
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            "Admin Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1A2E),
            ),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.verified_user, color: Color(0xFF0B3A8C)),
            title: Text("Roles & Permissions"),
            subtitle: Text("Manage admin roles and access levels"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.security, color: Color(0xFF0B3A8C)),
            title: Text("Security"),
            subtitle: Text("Password policy, 2FA, session rules"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: Color(0xFF0B3A8C)),
            title: Text("Notifications"),
            subtitle: Text("Enable or disable admin alerts"),
          ),
        ],
      ),
    );
  }
}
