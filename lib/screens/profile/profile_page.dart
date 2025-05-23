import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'edit_profile_page.dart';
import 'package:my_project/screens/settings/settings.dart';
import 'package:my_project/theme/theme_notifier.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onSettingsTap;

  const ProfilePage({Key? key, required this.onSettingsTap}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = 'User Not Found';
  String phoneNumber = '+63 956 789 9511';
  String? profileImagePath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentUsername: username,
          currentPhoneNumber: phoneNumber,
          currentProfileImagePath: profileImagePath,
          onProfileUpdated: (String newUsername, String newPhone, String? newImagePath) {}
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1A1A2E), Color(0xFF16213E)]
                      : const [Color(0xFF0A0E23), Color(0xFF6B4E1B)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Spacer(),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            if (themeNotifier.isDarkMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: theme.colorScheme.primary,
                child: const Center(
                  child: Text(
                    'Dark mode enabled',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 40),

            // 👤 Profile Picture
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: profileImagePath != null
                      ? FileImage(File(profileImagePath!))
                      : const AssetImage('assets/user.png') as ImageProvider,
                  child: profileImagePath == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                      : null,
                  backgroundColor: Colors.grey[400],
                ),
              ),
            ),

            const SizedBox(height: 10),

            //  Username Display
            Text(
              username,
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.black),
            ),

            const SizedBox(height: 5),
            Text(
              phoneNumber,
              style: TextStyle(color: Colors.black,
              fontSize: 16,
            ),
            ),


            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
