import 'package:flutter/material.dart';
import 'find_your_place_page.dart'; // ✅ Make sure this is correctly imported

class SetCurrentLocationPage extends StatefulWidget {
  const SetCurrentLocationPage({Key? key}) : super(key: key);

  @override
  State<SetCurrentLocationPage> createState() => _SetCurrentLocationPageState();
}

class _SetCurrentLocationPageState extends State<SetCurrentLocationPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ✅ Background image
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "assets/bg2.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: screenHeight,
              ),
            ),
          ),

          // ✅ Back button (top-left)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // ✅ Blue location image
          Positioned(
            top: screenHeight * 0.1,
            left: MediaQuery.of(context).size.width * 0.29,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/allow_loc.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // ✅ Title
          Positioned(
            top: screenHeight * 0.37,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Set current location',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ✅ "Find your place" button
          Positioned(
            top: screenHeight * 0.45,
            left: 73,
            right: 73,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindYourPlacePage(),
                  ),
                );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B55A0), Color.fromARGB(255, 7, 67, 127)],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Find your place',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(Icons.search, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
