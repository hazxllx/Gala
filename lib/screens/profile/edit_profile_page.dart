import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String currentUsername;
  final String? currentProfileImagePath;
  final Function(String, String, String?) onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.currentUsername,
    this.currentProfileImagePath,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  TextEditingController? _usernameController;
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String _currentUsername = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final parts = widget.currentUsername.split(' ');
    _firstNameController = TextEditingController(text: parts.first);
    _lastNameController = TextEditingController(
      text: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
    _selectedImagePath = widget.currentProfileImagePath;
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _currentUsername = data?['username'] ?? user.email?.split('@').first ?? '';
            _usernameController = TextEditingController(text: _currentUsername);
            _isLoading = false;
          });
        } else {
          setState(() {
            _currentUsername = user.email?.split('@').first ?? '';
            _usernameController = TextEditingController(text: _currentUsername);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentUsername = user.email?.split('@').first ?? '';
            _usernameController = TextEditingController(text: _currentUsername);
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _usernameController = TextEditingController(text: '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
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

  Future<String?> _uploadImageToStorage(String imagePath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final file = File(imagePath);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> _isUsernameAvailable(String username) async {
    if (username.toLowerCase() == _currentUsername.toLowerCase()) {
      return true;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final newUsername = _usernameController?.text.trim().toLowerCase() ?? '';
      
      // Check username availability
      if (newUsername.isNotEmpty) {
        final isAvailable = await _isUsernameAvailable(newUsername);
        if (!isAvailable) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username is already taken. Please choose another.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() {
            _isUploading = false;
          });
          return;
        }
      }

      String? photoUrl = widget.currentProfileImagePath;

      // Upload new image if selected
      if (_selectedImagePath != null &&
          _selectedImagePath != widget.currentProfileImagePath) {
        final uploadedUrl = await _uploadImageToStorage(_selectedImagePath!);
        if (uploadedUrl != null) {
          photoUrl = uploadedUrl;
        }
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'username': newUsername,
        'email': user.email,
        'photoUrl': photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      // Update callback
      widget.onProfileUpdated(
        fullName.trim(),
        '',
        photoUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated Successfully!'),
            backgroundColor: Color(0xFF0B55A0),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1.3,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: false,
        ),
        backgroundColor: const Color(0xFFF7F9FB),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0B55A0),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1.3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF0B55A0).withValues(alpha: 0.13),
                    backgroundImage: _selectedImagePath != null
                        ? (_selectedImagePath!.startsWith('http')
                            ? NetworkImage(_selectedImagePath!)
                            : FileImage(File(_selectedImagePath!)) as ImageProvider)
                        : null,
                    child: _selectedImagePath == null
                        ? Icon(Icons.person, size: 56, color: Colors.grey[300])
                        : null,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B55A0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(7),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF0B55A0), width: 1.2),
                ),
                child: TextFormField(
                  controller: _firstNameController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person, color: Color(0xFF0B55A0)),
                    labelText: 'First Name',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 8),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter first name'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF0B55A0), width: 1.2),
                ),
                child: TextFormField(
                  controller: _lastNameController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0B55A0)),
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 8),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter last name'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF0B55A0), width: 1.2),
                ),
                child: TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(fontSize: 17),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.alternate_email, color: Color(0xFF0B55A0)),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return 'Username can only contain letters, numbers, and underscores';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B55A0),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
