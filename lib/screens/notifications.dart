import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(
        'Favorites',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  );
}

class ProfilePage extends StatelessWidget {
  final String username;
  final VoidCallback onSettingsTap;

  const ProfilePage({super.key, required this.username, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            username,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: onSettingsTap,
            child: const Text('Settings'),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Settings',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  );
}

class NotificationsPage extends StatefulWidget {
  final String? username;

  const NotificationsPage({super.key, this.username});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (mounted) {
          setState(() {
            _userPhotoUrl = data?['photoURL'] ?? user.photoURL;
          });
        }
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        if (mounted) {
          setState(() {
            _userPhotoUrl = user.photoURL;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 10,
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                CircleAvatar(
                  backgroundImage: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                      ? NetworkImage(_userPhotoUrl!)
                      : const AssetImage('assets/user.png') as ImageProvider,
                  radius: 18,
                  backgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  onBackgroundImageError: (exception, stackTrace) {
                    debugPrint("Error loading user photo: $exception");
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
