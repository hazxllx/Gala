import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/screens/settings/settings.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onLogout;

  const Sidebar({super.key, required this.onLogout});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _username = "User Not Found";
  String _email = "usernotfound23";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();

        setState(() {
          _username = data?['username'] ?? user.displayName ?? "No Name";
          _email = user.email ?? "No Email";
        });
      } catch (e) {
        debugPrint("Error fetching user: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[700];
    final dividerColor = isDark ? Colors.grey[700] : Colors.black12;
    final iconColor = textColor;

    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 5),

          /// 👤 User Profile Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            color: Theme.of(context).drawerTheme.backgroundColor ?? Theme.of(context).canvasColor,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: TextStyle(fontSize: 14, color: subTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 📋 Navigation
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(Icons.home, "Home", iconColor, textColor, () => _navigateTo(context, 0)),
                _buildSidebarItem(Icons.explore, "Explore", iconColor, textColor, () => _navigateTo(context, 1)),
                _buildSidebarItem(Icons.history, "History", iconColor, textColor, () => _navigateTo(context, 2)),
                _buildSidebarItem(Icons.notifications, "Notifications", iconColor, textColor, () => _navigateTo(context, 3)),
                _buildSidebarItem(Icons.bookmark, "Favorites", iconColor, textColor, () => _navigateTo(context, 4)),
                _buildSidebarItem(Icons.person, "Profile", iconColor, textColor, () => _navigateTo(context, 5)),
                _buildSidebarItem(Icons.settings, "Settings", iconColor, textColor, () => _navigateTo(context, 6)),

                Divider(color: dividerColor),

                /// 🔓 Logout
                _buildSidebarItem(Icons.logout, "Logout", iconColor, textColor, _handleLogout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String text,
    Color iconColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, int index) {
    Navigator.pop(context); // Close the drawer
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homepage');
        break;
      case 4:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 5:
        Navigator.pushNamed(context, '/profile', arguments: {
          'onSettingsTap': () => Navigator.pushNamed(context, '/settings'),
        });
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Feature not implemented')));
    }
  }

  /// 🔐 Real logout logic
  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      widget.onLogout(); // Callback to app for navigation or cleanup
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }
}
