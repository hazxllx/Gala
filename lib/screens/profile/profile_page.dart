import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart'; // Ensure this import exists

class ProfilePage extends StatefulWidget {
  final VoidCallback onSettingsTap;
  const ProfilePage({
    super.key,
    required this.onSettingsTap,
    required String username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String photoUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!mounted) return;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safePaddingTop = MediaQuery.of(context).padding.top;

    final fullName = (firstName + ' ' + lastName).trim().isEmpty
        ? 'User Not Found'
        : '$firstName $lastName';
    final userName =
        FirebaseAuth.instance.currentUser?.email?.split('@').first ??
            'usernotfound23';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black54,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.onSettingsTap,
              child: Image.asset(
                'assets/icons/settings.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_settings.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main white panel
          Positioned(
            top: safePaddingTop + size.height * 0.18,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: size.height * 0.03,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: size.width * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.015),

                          SizedBox(
                            width: size.width * 0.4,
                            height: size.height * 0.045,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      currentUsername: fullName,
                                      currentProfileImagePath: photoUrl.isNotEmpty
                                          ? photoUrl
                                          : null,
                                      onProfileUpdated: (updatedUsername, _, updatedImagePath) {
                                        final parts = updatedUsername.split(' ');
                                        setState(() {
                                          firstName = parts.first;
                                          lastName = parts.length > 1
                                              ? parts.sublist(1).join(' ')
                                              : '';
                                          photoUrl = updatedImagePath ?? photoUrl;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Edit profile',
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.06),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Account',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              userName,
                              style: TextStyle(
                                fontSize: size.width * 0.038,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: TextStyle(
                                fontSize: size.width * 0.035,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Your Activity',
                              style: TextStyle(
                                fontSize: size.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03,
                              horizontal: size.width * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: size.width * 0.08,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Text(
                                  'No Activity yet',
                                  style: TextStyle(
                                    fontSize: size.width * 0.035,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  'Your recent activities will appear here',
                                  style: TextStyle(
                                    fontSize: size.width * 0.03,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
            ),
          ),

          // Profile avatar circle
          Positioned(
            top: safePaddingTop + size.height * 0.10,
            left: (size.width / 2) - (size.width * 0.12),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: size.width * 0.12,
                backgroundColor: Colors.white,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/user.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
