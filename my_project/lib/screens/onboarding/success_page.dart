import 'package:flutter/material.dart';

class LocationConfirmedPage extends StatelessWidget {
  final String location;

  const LocationConfirmedPage({Key? key, required this.location})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents resize on keyboard open
      body: Container(
        width: double.infinity,
        height: double.infinity, // full screen height
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 150), // 👈 pushes image downward
                  Expanded(
                    child: Image.asset("assets/bg2.png", fit: BoxFit.cover),
                  ),
                ],
              ),
            ),

            // Blue location image
            Positioned(
              top: MediaQuery.of(context).size.height * 0.099,
              left: MediaQuery.of(context).size.width * 0.29,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/success.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Greeting
            Positioned(
              top: MediaQuery.of(context).size.height * 0.31,
              left: 0,
              right: 0,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Successful !',
                        style: TextStyle(
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

            // Description
            Positioned(
              top: MediaQuery.of(context).size.height * 0.38,
              left: 60,
              right: 60,
              child: Text(
                'Your location is set! Start exploring nearby spots and personalized recommendations now.\n\nYour location: $location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.52,
              left: 73,
              right: 73,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/homepage');
                },
                child: Container(
                  height: 40,
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
