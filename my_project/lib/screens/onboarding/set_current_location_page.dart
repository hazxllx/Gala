import 'package:flutter/material.dart';

class SetCurrentLocationPage extends StatefulWidget {
  const SetCurrentLocationPage({Key? key}) : super(key: key);

  @override
  State<SetCurrentLocationPage> createState() => _AllowLocationPageState();
}

class _AllowLocationPageState extends State<SetCurrentLocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Expanded(
                    child: Image.asset("assets/bg2.png", fit: BoxFit.cover),
                  ),
                ],
              ),
            ),

            // Blue location image
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
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

            // Greeting
            Positioned(
              top: MediaQuery.of(context).size.height * 0.34,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Set current location',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Description
            Positioned(
              top: MediaQuery.of(context).size.height * 0.40,
              left: 60,
              right: 60,
              child: Text(
                'Manually set your location to find places nearby and get relevant recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.6,
                ),
              ),
            ),

            // "Find your place" button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.50,
              left: 73,
              right: 73,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/find_your_place');
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0B55A0),
                        Color.fromARGB(255, 7, 67, 127),
                      ],
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
      ),
    );
  }
}
