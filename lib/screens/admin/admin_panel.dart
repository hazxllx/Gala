import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';
import 'establishments_page.dart';
import 'users_page.dart';
// IMPORTANT: your admin settings file should export AdminSettingsPage
import 'settings_page.dart' show AdminSettingsPage;

/// ------------------------------
/// THEME / COLORS
/// ------------------------------
class AdminColors {
  static const primary = Color(0xFF0B3A8C);
  static const primaryDark = Color(0xFF083071);
  static const primaryLight = Color(0xFF1F65D6);
  static const surface = Colors.white;
  static const subtleBg = Color(0xFFF5F8FF);
  static const border = Color(0xFFE6ECF8);
  static const textPrimary = Color(0xFF0F1A2E);
  static const textSecondary = Color(0xFF4D5B7C);
  static const success = Color(0xFF1B9E5A);
  static const danger = Color(0xFFD64545);
}

/// ------------------------------
/// MAIN ADMIN PAGE
/// ------------------------------
class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    EstablishmentsPage(),
    UsersPage(),
    AdminSettingsPage(), // <-- use the admin settings class
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.subtleBg,
      appBar: AppBar(
        backgroundColor: AdminColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _getTitle(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: _pages[_selectedIndex],
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Establishments";
      case 2:
        return "Users";
      case 3:
        return "Settings";
      default:
        return "Admin Panel";
    }
  }

  /// ------------------------------
  /// SIDE DRAWER
  /// ------------------------------
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AdminColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: AdminColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: const Center(
              child: Text(
                "ADMIN PANEL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          _drawerItem(Icons.dashboard, "Dashboard", 0),
          _drawerItem(Icons.store_mall_directory, "Establishments", 1),
          _drawerItem(Icons.people, "Users", 2),
          _drawerItem(Icons.settings, "Settings", 3),

          const Spacer(),
          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AdminColors.danger),
            title: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              // Sign out and clear local session
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                // Go to login screen; remove all routes
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// ------------------------------
  /// DRAWER ITEM HELPER
  /// ------------------------------
  Widget _drawerItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AdminColors.primary : AdminColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AdminColors.primary : AdminColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      selectedTileColor: AdminColors.subtleBg,
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
