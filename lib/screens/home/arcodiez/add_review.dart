import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddReviewPage extends StatefulWidget {
  final String cafeTitle;
  const AddReviewPage({super.key, required this.cafeTitle});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  File? _selectedImage;
  bool isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('reviews/${widget.cafeTitle}/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }
    if (selectedRating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a comment.')),
      );
      return;
    }
    setState(() => isSubmitting = true);

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
    }

    // Save review in Firestore (multiple reviews per user allowed)
    await FirebaseFirestore.instance
        .collection('cafes')
        .doc(widget.cafeTitle)
        .collection('reviews')
        .add({
      'rating': selectedRating,
      'comment': _commentController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'userPhotoUrl': user.photoURL ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => isSubmitting = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Thank You!'),
        content: Text('Your review has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // pop review page
              setState(() {
                selectedRating = 0;
                _commentController.clear();
                _selectedImage = null;
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/arco_diez.jpg',
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Review Content
          Positioned.fill(
            top: 200,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Text
                    Center(
                      child: Text(
                        'Give it a rate!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            size: 32,
                            color: selectedRating > index
                                ? Color(0xFF0B55A0)
                                : Colors.grey[300],
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    // Labels under stars
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Bad', style: TextStyle(fontSize: 12)),
                          Text('Excellent', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // New Add Review Input Container
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Please share your opinion about ${widget.cafeTitle}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 180,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: _commentController,
                              maxLines: null,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Type something...',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _pickImage,
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF0B55A0),
                                ),
                              ),
                              Text("Add your photo"),
                              Spacer(),
                              ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : (selectedRating > 0 &&
                                            _commentController.text
                                                .trim()
                                                .isNotEmpty)
                                        ? _submitReview
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (selectedRating > 0 &&
                                          _commentController.text
                                              .trim()
                                              .isNotEmpty)
                                      ? Color(0xFF0B55A0)
                                      : Colors.white,
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: isSubmitting
                                    ? SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0B55A0),
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : Text(
                                        'SEND REVIEW',
                                        style: TextStyle(
                                          color: (selectedRating > 0 &&
                                                  _commentController.text
                                                      .trim()
                                                      .isNotEmpty)
                                              ? Colors.white
                                              : Color(0xFF0B55A0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                          if (_selectedImage != null) ...[
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
