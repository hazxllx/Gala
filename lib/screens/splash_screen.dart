import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final bool showButtons;

  const SplashScreen({Key? key, required this.showButtons}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.showButtons) {
      // If buttons are not shown, navigate to onboarding after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A71A9), Color(0xFF041D66)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Logo and Gala Image - Centered with responsive positioning
              Positioned(
                top: widget.showButtons 
                    ? screenHeight * 0.15 // Higher when buttons are shown
                    : screenHeight * 0.25, // More centered when no buttons
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with responsive sizing
                    Image.asset(
                      'assets/logoWhite.png',
                      height: screenHeight * 0.25, // 25% of screen height
                      width: screenWidth * 0.8, // 80% of screen width
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.01), // 1% of screen height
                    // Gala image with responsive sizing
                    Image.asset(
                      'assets/Gala.png',
                      height: screenHeight * 0.1, // 10% of screen height
                      width: screenWidth * 0.4, // 40% of screen width
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // Buttons at bottom (only show if showButtons is true)
              if (widget.showButtons)
                Positioned(
                  bottom: safeAreaBottom + (screenHeight * 0.08), // Responsive bottom padding
                  left: screenWidth * 0.05, // 5% margin from sides
                  right: screenWidth * 0.05, // 5% margin from sides
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Login Button
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: 350,
                          minHeight: screenHeight * 0.06, // Minimum 6% of screen height
                        ),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02, // 2% of screen height
                              horizontal: 20,
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
                      // Sign Up Button
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: 350,
                          minHeight: screenHeight * 0.06, // Minimum 6% of screen height
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02, // 2% of screen height
                              horizontal: 20,
                            ),
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}