import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:my_project/screens/favorites.dart' as fav;
import 'package:my_project/screens/notifications.dart' as notif;
import 'package:my_project/screens/settings/settings.dart';
import 'package:my_project/screens/partner/partner_submission_page.dart';

class Sidebar extends StatefulWidget {
  final VoidCallback onLogout;

  const Sidebar({super.key, required this.onLogout});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String _username = "User Not Found";
  String _email = "usernotfound23";
  User? _user;

  static const Color headerBlue = Color.fromARGB(146, 125, 179, 255);
  static const Color iconAndTextColor = Color(0xFF23272F);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
        final data = doc.data();

        setState(() {
          _username = data?['username'] ?? _user!.displayName ?? "No Name";
          _email = _user!.email ?? "No Email";
        });
      } catch (e) {
        debugPrint("Error fetching user info: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: const BoxDecoration(
              color: headerBlue,
              borderRadius: BorderRadius.zero,
              boxShadow: [
                BoxShadow(
                  color: Color(0x13000000),
                  blurRadius: 5,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage: _user != null && _user!.photoURL != null
                      ? NetworkImage(_user!.photoURL!)
                      : const AssetImage('assets/user.png') as ImageProvider,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: iconAndTextColor,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: iconAndTextColor,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _sidebarItem(
                  icon: Icons.home,
                  label: "Home",
                  onTap: () => _navigateTo(context, 0),
                ),
                _sidebarItem(
                  icon: Icons.notifications,
                  label: "Notifications",
                  onTap: () => _navigateTo(context, 1),
                ),
                _sidebarItem(
                  icon: Icons.bookmark,
                  label: "Favorites",
                  onTap: () => _navigateTo(context, 2),
                ),
                _sidebarItem(
                  icon: Icons.person,
                  label: "Profile",
                  onTap: () => _navigateTo(context, 3),
                ),
                _sidebarItem(
                  icon: Icons.settings,
                  label: "Settings",
                  onTap: () => _navigateTo(context, 4),
                ),
                const SizedBox(height: 8),
                _sidebarItem(
                  icon: Icons.handshake,
                  label: "Partner With Us",
                  onTap: () => _navigateTo(context, 5),
                ),
                const SizedBox(height: 8),
                _sidebarItem(
                  icon: Icons.logout,
                  label: "Logout",
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 100), onTap);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconAndTextColor,
                size: 24,
              ),
              const SizedBox(width: 18),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: iconAndTextColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/homepage');
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const notif.NotificationsPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const fav.FavoritesScreen()),
        );
        break;
      case 3:
        Navigator.pushNamed(context, '/profile', arguments: {
          'onSettingsTap': () => Navigator.pushNamed(context, '/settings'),
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PartnerSubmissionPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature not implemented')),
        );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      widget.onLogout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }
}
