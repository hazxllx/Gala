// --- NO CHANGES TO IMPORTS
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_page.dart';
import 'report_problem_page.dart';
import 'privacy_settings_page.dart';
import 'package:my_project/theme/theme_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool locationEnabled = true;
  bool dataCollectionEnabled = true;
  bool analyticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      locationEnabled = prefs.getBool('location_enabled') ?? true;
      dataCollectionEnabled = prefs.getBool('data_collection_enabled') ?? true;
      analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      notificationsEnabled = value;
    });
    await _saveSetting('notifications_enabled', value);
    showMessage(context, "Notifications ${value ? 'enabled' : 'disabled'}");
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context);
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_settings.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 140, // Reduced height to move elements up
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24), // Reduced bottom padding
                    child: Column(
                      children: [
                        buildSection(
                          'Account',
                          [
                            SettingItem(
                              icon: Icons.lock_outline,
                              title: 'Change Password',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChangePasswordPage(),
                                  ),
                                );
                              },
                            ),
                            SwitchSettingItem(
                              icon: Icons.notifications_none,
                              title: 'Notifications',
                              value: notificationsEnabled,
                              onChanged: _toggleNotifications,
                            ),
                            SettingItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrivacySettingsPage(
                                      locationEnabled: locationEnabled,
                                      dataCollectionEnabled: dataCollectionEnabled,
                                      analyticsEnabled: analyticsEnabled,
                                      onSettingsChanged: (
                                        location,
                                        dataCollection,
                                        analytics,
                                      ) async {
                                        setState(() {
                                          locationEnabled = location;
                                          dataCollectionEnabled = dataCollection;
                                          analyticsEnabled = analytics;
                                        });
                                        await _saveSetting('location_enabled', location);
                                        await _saveSetting('data_collection_enabled', dataCollection);
                                        await _saveSetting('analytics_enabled', analytics);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            SettingItem(
                              icon: Icons.store_mall_directory_outlined,
                              title: 'Apply as a Business Owner',
                              onTap: () {
                                showMessage(context, "Apply flow coming soon...");
                              },
                            ),
                          ],
                          isDark,
                          theme,
                        ),
                        const SizedBox(height: 8), // Reduced space between sections
                        buildSection(
                          'Preferences',
                          [
                            SwitchSettingItem(
                              icon: Icons.dark_mode_outlined,
                              title: 'Dark Mode',
                              value: isDark,
                              onChanged: (val) async {
                                themeProvider.toggleTheme();
                                await _saveSetting('dark_mode', val);
                                showMessage(context, "Dark mode ${val ? 'enabled' : 'disabled'}");
                              },
                            ),
                          ],
                          isDark,
                          theme,
                        ),
                        const SizedBox(height: 8), // Reduced space between sections
                        buildSection(
                          'Actions',
                          [
                            SettingItem(
                              icon: Icons.flag_outlined,
                              title: 'Report a problem',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReportProblemPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                          isDark,
                          theme,
                        ),
                        const SizedBox(height: 16), // Reduced bottom space
                        Text(
                          'Gala App v1.0.0',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, List<Widget> items, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor.withOpacity(0.85) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const SettingItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: titleColor ?? (isDark ? Colors.white : Colors.black),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.white54 : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class SwitchSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}
