import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Dummy pages for navigation
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Text(
        'Favorites',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  );
}

class ProfilePage extends StatelessWidget {
  final String username;
  final VoidCallback onSettingsTap;

  ProfilePage({required this.username, required this.onSettingsTap});

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
            child: Text('Settings'),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage();

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
  _NotificationsPageState createState() => _NotificationsPageState();
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
          // Custom AppBar
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
                // Back Arrow Icon
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Title "Notifications"
                    Text(
            'Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),

                // User Photo on the right - synced with real user data
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

          // Main Body content
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
                  // Today heading
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // No notifications message centered
                  Expanded(
                    child: Center(
                      child: Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
