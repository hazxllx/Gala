import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  final bool locationEnabled;
  final bool dataCollectionEnabled;
  final bool analyticsEnabled;
  final Function(bool, bool, bool) onSettingsChanged;

  const PrivacySettingsPage({
    Key? key,
    required this.locationEnabled,
    required this.dataCollectionEnabled,
    required this.analyticsEnabled,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late bool _locationEnabled;
  late bool _dataCollectionEnabled;
  late bool _analyticsEnabled;

  @override
  void initState() {
    super.initState();
    _locationEnabled = widget.locationEnabled;
    _dataCollectionEnabled = widget.dataCollectionEnabled;
    _analyticsEnabled = widget.analyticsEnabled;
  }

  void _updateSettings() {
    widget.onSettingsChanged(_locationEnabled, _dataCollectionEnabled, _analyticsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    // Get theme information
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Settings',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            buildSection(
              'Location Services',
              [
                SwitchSettingItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location Access',
                  subtitle: 'Allow app to access your location for better recommendations',
                  value: _locationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _locationEnabled = value;
                    });
                    _updateSettings();
                  },
                ),
              ],
              isDark,
              theme,
            ),
            const SizedBox(height: 16),
            buildSection(
              'Data & Privacy',
              [
                SwitchSettingItem(
                  icon: Icons.data_usage_outlined,
                  title: 'Data Collection',
                  subtitle: 'Allow app to collect usage data to improve services',
                  value: _dataCollectionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _dataCollectionEnabled = value;
                    });
                    _updateSettings();
                  },
                ),
                SwitchSettingItem(
                  icon: Icons.analytics_outlined,
                  title: 'Analytics',
                  subtitle: 'Allow app to collect anonymous analytics data',
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _analyticsEnabled = value;
                    });
                    _updateSettings();
                  },
                ),
              ],
              isDark,
              theme,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your privacy is important to us. We only collect data that helps us improve your experience. You can change these settings at any time.',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> items, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

class SwitchSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchSettingItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
} 