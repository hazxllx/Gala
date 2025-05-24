import 'package:flutter/material.dart';

class SetLocationPage extends StatelessWidget {
  const SetLocationPage({Key? key}) : super(key: key);

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
              top: MediaQuery.of(context).size.height * 0.065,
              left: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 202,
                height: 202,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/blueloc.png"),
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
                        text: 'Hi, ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: 'User!',
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
              top: MediaQuery.of(context).size.height * 0.37,
              left: 60,
              right: 60,
              child: Text(
                'Please choose how you want to set your location to start exploring places around you.',
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

            // "Allow Location" button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.47,
              left: 73,
              right: 73,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/allow_location');
                },

                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF1A907), Color(0xFFE4A10C)],
                    ),
                    borderRadius: BorderRadius.circular(56),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3.3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
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

            // "Set Current Location" button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.53,
              left: 73,
              right: 73,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/set_current_location');
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF0B55A0),
                    borderRadius: BorderRadius.circular(56),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
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
