import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart'; // Ensure this import exists

class ProfilePage extends StatefulWidget {
  final VoidCallback onSettingsTap;
  const ProfilePage({
    super.key,
    required this.onSettingsTap, required String username,
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

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = data['email'] ?? '';
        photoUrl = data['photoUrl'] ?? '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (firstName + ' ' + lastName).trim().isEmpty
        ? 'User Not Found'
        : '$firstName $lastName';
    final userName =
        FirebaseAuth.instance.currentUser?.email?.split('@').first ??
            'usernotfound23';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg_settings.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  currentUsername: '$firstName $lastName',
                                  currentProfileImagePath: photoUrl.isNotEmpty
                                      ? photoUrl
                                      : null,
                                  onProfileUpdated:
                                      (updatedUsername, _, updatedImagePath) {
                                    final parts = updatedUsername.split(' ');
                                    setState(() {
                                      firstName = parts.first;
                                      lastName = parts.length > 1
                                          ? parts.sublist(1).join(' ')
                                          : '';
                                      photoUrl =
                                          updatedImagePath ?? photoUrl;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Edit profile',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Account',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Your Activity',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/user.png') as ImageProvider,
            ),
          ),
        ],
      ),
    );
  }
}
