import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetLocationPage extends StatefulWidget {
  const SetLocationPage({Key? key}) : super(key: key);

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage> {
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['username'] != null) {
        setState(() {
          _username = data['username'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: screenHeight,
        color: Colors.white,
        child: Stack(
          children: [
            // ✅ Background image
            Positioned.fill(
              child: Image.asset(
                "assets/bg2.png",
                fit: BoxFit.cover,
              ),
            ),

            // ✅ Back button
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // ✅ Blue location image
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.25,
              child: Container(
                width: 202,
                height: 202,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/blueloc.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ✅ Greeting
            Positioned(
              top: screenHeight * 0.35,
              left: 20,
              right: 20,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Hi, ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: '$_username!',
                        style: const TextStyle(
                          color: Color(0xFF0B55A0),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // ✅ Description
            Positioned(
              top: screenHeight * 0.42,
              left: 40,
              right: 40,
              child: Center(
                child: Text(
                  'Please choose how you want to set your location to start exploring places around you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.85),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            // ✅ Allow Location button
            Positioned(
              top: screenHeight * 0.52,
              left: 60,
              right: 60,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/allow_location');
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF1A907), Color(0xFFE4A10C)],
                    ),
                    borderRadius: BorderRadius.circular(56),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3.3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Allow Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Set Current Location button
            Positioned(
              top: screenHeight * 0.60,
              left: 60,
              right: 60,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/set_current_location');
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B55A0),
                    borderRadius: BorderRadius.circular(56),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Set Current Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
