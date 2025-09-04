import 'package:flutter/material.dart';

class LocationConfirmedPage extends StatelessWidget {
  final String location;

  const LocationConfirmedPage({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: double.infinity,
        height: screenHeight,
        child: Stack(
          children: [
            // ✅ Background image moved down
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              height: screenHeight - 100,
              child: Image.asset(
                "assets/bg2.png",
                fit: BoxFit.cover,
              ),
            ),

            // ✅ Success icon
            Positioned(
              top: screenHeight * 0.10,
              left: MediaQuery.of(context).size.width * 0.29,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/success.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ✅ Title text
            Positioned(
              top: screenHeight * 0.36,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Successful!',
                  style: TextStyle(
                    color: Color(0xFF0B55A0),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),

            // ✅ Clean description text
            Positioned(
              top: screenHeight * 0.42,
              left: 40,
              right: 40,
              child: Text(
                'Your location is set! Start exploring nearby spots and personalized recommendations now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),

            // ✅ Button
            Positioned(
              top: screenHeight * 0.55,
              left: 73,
              right: 73,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/homepage');
                },
                child: Container(
                  height: 42,
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
                      'Start Exploring!',
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
