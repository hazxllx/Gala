/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-010] Setting
Description: The settings page lets users toggle dark mode 
and manage account preferences like password, notifications, and log out.
 */

//The settings page allows users to toggle dark mode and manage account preferences like password 
//changes, notifications, privacy, and log out. 

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'darkmode.dart';

// SettingsPage Widget: A stateful widget for the settings screen.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Toggles dark mode when the switch is changed.
  void toggleDarkMode(bool value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleTheme(value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // Background image with dark mode filter
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/bg_settings.png'),
                fit: BoxFit.cover,
                colorFilter: isDarkMode
                    ? ColorFilter.mode(Color.fromRGBO(0, 0, 0, 0.5), BlendMode.darken)
                    : null,
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black87 : Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                children: [
                  // Account settings section
                  _sectionTitle('Account', isDarkMode),
                  _settingsTile(Icons.lock, 'Change Password', isDarkMode),
                  _settingsTile(Icons.notifications, 'Notifications', isDarkMode),
                  _settingsTile(Icons.privacy_tip, 'Privacy', isDarkMode),
                  // Preferences section with dark mode toggle
                  _sectionTitle('Preferences', isDarkMode),
                  _darkModeSwitch(isDarkMode),
                  // Actions section
                  _sectionTitle('Actions', isDarkMode),
                  _settingsTile(Icons.report_problem, 'Report a problem', isDarkMode),
                  _settingsTile(Icons.logout, 'Log out', isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section title widget
  Widget _sectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Text(title, style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }

  // Settings tile widget
  Widget _settingsTile(IconData icon, String title, bool isDarkMode) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3.0),
      leading: Icon(icon, color: isDarkMode ? Colors.white : Colors.black),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.white54 : Colors.black45),
    );
  }

  // Dark mode switch widget
  Widget _darkModeSwitch(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 3.0),
        leading: Icon(Icons.dark_mode, color: isDarkMode ? Colors.white : Colors.black),
        title: Text('Dark Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black)),
        trailing: Switch(value: isDarkMode, onChanged: toggleDarkMode, activeColor: Colors.blue),
      ),
    );
  }
}
