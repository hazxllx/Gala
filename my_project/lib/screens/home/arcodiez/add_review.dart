import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddReviewPage extends StatefulWidget {
  const AddReviewPage({super.key});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  int selectedRating = 0;

  final TextEditingController _commentController = TextEditingController();

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
                            color:
                                selectedRating > index
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

                    // Ratings Panel
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ratingBox(
                            'Foursquare',
                            'Not rated yet',
                            'assets/images/fsq.png',
                          ),
                          ratingBox(
                            'Google',
                            '4.4★',
                            'assets/images/google.png',
                          ),
                          ratingBox('Facebook', '3.7★', 'assets/images/fb.png'),
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
                              'Please share your opinion about Arco Diez Cafe',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign:
                                  TextAlign
                                      .center, // Optional, but good practice for multi-line
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
                                onPressed: () {
                                  if (selectedRating == 0 ||
                                      _commentController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please provide a rating and a comment.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: Text('Thank You!'),
                                            content: Text(
                                              'Your review has been submitted successfully.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                    context,
                                                  ); // Close dialog
                                                  Navigator.pop(
                                                    context,
                                                  ); // Navigate back

                                                  // Clear form only after pop
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

                                    // Optionally clear form
                                    setState(() {
                                      selectedRating = 0;
                                      _commentController.clear();
                                      _selectedImage = null;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0B55A0),
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  'SEND REVIEW',
                                  style: TextStyle(
                                    color: Colors.white,
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

                    // Visitor's Reviews Header
                    SizedBox(height: 12),
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

  Widget ratingBox(String source, String rating, String iconPath) {
    return Column(
      children: [
        Image.asset(iconPath, width: 32, height: 32),
        SizedBox(height: 8),
        Text(rating, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(source, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget reviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(review['avatar']),
                radius: 20,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    review['time'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color:
                    index < review['rating'] ? Colors.orange : Colors.grey[300],
              );
            }),
          ),
          SizedBox(height: 8),
          Text(review['comment'], style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
