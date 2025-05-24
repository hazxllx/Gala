/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-016] Sidebar
Description: The Sidebar widget is a navigation drawer that provides access to various app sections and settings.
 */

// The purpose of the Sidebar widget is to provide a sliding navigation menu for accessing different sections and
// settings.

import 'package:flutter/material.dart';
import 'package:my_project/screens/settings/settings.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onLogout;

  const Sidebar({super.key, required this.onLogout});

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

          /// User Profile
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
            color:
                Theme.of(context).drawerTheme.backgroundColor ??
                Theme.of(context).canvasColor,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor: Color.fromARGB(0, 20, 20, 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Not Found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "usernotfound23",
                      style: TextStyle(fontSize: 14, color: subTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSidebarItem(
                  Icons.home,
                  "Home",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 0),
                ),
                _buildSidebarItem(
                  Icons.explore,
                  "Explore",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 1),
                ),
                _buildSidebarItem(
                  Icons.history,
                  "History",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 2),
                ),
                _buildSidebarItem(
                  Icons.notifications,
                  "Notifications",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 3),
                ),
                _buildSidebarItem(
                  Icons.bookmark,
                  "Favorites",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 4),
                ),
                _buildSidebarItem(
                  Icons.person,
                  "Profile",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 5),
                ),
                _buildSidebarItem(
                  Icons.settings,
                  "Settings",
                  iconColor,
                  textColor,
                  () => _navigateTo(context, 6),
                ),

                Divider(color: dividerColor),

                _buildSidebarItem(
                  Icons.logout,
                  "Logout",
                  iconColor,
                  textColor,
                  onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer item
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

  /// Navigation logic
  void _navigateTo(BuildContext context, int index) {
    Navigator.pop(context); // Close the drawer

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homepage');
        break;

      case 4: // <-- Add this for Favorites page
        Navigator.pushNamed(context, '/favorites');
        break;

      case 5:
        Navigator.pushNamed(
          context,
          '/profile',
          arguments: {
            'onSettingsTap': () => Navigator.pushNamed(context, '/settings'),
          },
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;

      case 7:
        Navigator.pushNamed(
          context,
          '/homepage',
          arguments: {'username': 'your_username_here'},
        );

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Feature not implemented')));
    }
  }
}
