import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  final Future<void> Function(BuildContext) onboardingCompleted;

  const OnboardingPage({Key? key, required this.onboardingCompleted})
      : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Texts for each slide
  final List<String> headings = [
    'Mabuhay, Explorer!',
    'Find Your Way',
    'Your Travel Buddy is Here!',
  ];

  final List<String> onboardingTexts = [
    "Your journey begins here. Let's explore the best cafes, restaurants, and parks in Camarines Sur!",
    "Get accurate directions, transport options, and fare details to reach your destination easily.",
    "Plan your trips with ease. Check locations, menus, and transport in just one app!",
  ];

  // Background images for each slide (make sure these assets exist)
  final List<String> bgImages = [
    'assets/onboarding1.png', // slide 1 bg
    'assets/onboarding2.png', // slide 2 bg
    'assets/onboarding3.png', // slide 3 bg
  ];

  void _nextPage() {
    if (_currentPage < onboardingTexts.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onboardingCompleted(context);
    }
  }

  void _skip() {
    widget.onboardingCompleted(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        top: false, // Allow background image to extend to top
        child: Stack(
          children: [
            // 1. Full screen image background
            PageView.builder(
              controller: _pageController,
              itemCount: onboardingTexts.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (_, index) {
                return Container(
                  width: double.infinity,
                  height: screenHeight,
                  child: Image.asset(
                    bgImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: screenHeight,
                  ),
                );
              },
            ),

            // 2. Overlay container with responsive positioning
            Positioned(
              top: _getContentTopPosition(screenHeight, safeAreaTop),
              bottom: _getContentBottomPosition(screenHeight, safeAreaBottom),
              left: 0,
              right: 0,
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06, // 6% of screen width
                  vertical: screenHeight * 0.02, // 2% of screen height
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Heading with responsive font size
                    _buildHeading(screenWidth),

                    SizedBox(height: screenHeight * 0.02), // 2% of screen height

                    // Body text with responsive constraints
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * 0.8, // 80% of screen width
                      ),
                      child: Text(
                        onboardingTexts[_currentPage],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Responsive font size
                          color: Colors.grey[800],
                          height: 1.4, // Line height for better readability
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03), // 3% of screen height

                    // Page indicators with responsive sizing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardingTexts.length, (index) {
                        return Container(
                          width: screenWidth * 0.02, // Responsive dot size
                          height: screenWidth * 0.02,
                          margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: screenHeight * 0.06), // 6% of screen height

                    // Buttons row with responsive sizing
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skip,
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04, // Responsive font
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018, // Responsive padding
                              ),
                              backgroundColor: const Color(0xFFF5F5F5),
                              side: const BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              shadowColor: Colors.black.withOpacity(0.8),
                              elevation: 4,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04), // Responsive spacing
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_currentPage == onboardingTexts.length - 1) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool(
                                  'onboarding_completed',
                                  true,
                                );
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/splash_auth', // Navigate to splash with buttons
                                );
                              } else {
                                _nextPage();
                              }
                            },
                            child: Text(
                              _currentPage == onboardingTexts.length - 1
                                  ? "Done"
                                  : "Next",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04, // Responsive font
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.018, // Responsive padding
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                5,
                                56,
                                145,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              shadowColor: Colors.black.withOpacity(0.8),
                              elevation: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get responsive top position for content
  double? _getContentTopPosition(double screenHeight, double safeAreaTop) {
    if (_currentPage == 1) {
      // Slide 2 positioned from top
      return safeAreaTop + (screenHeight * 0.08); // 8% from safe area top
    }
    return null; // Slides 1 & 3 positioned from bottom
  }

  // Helper method to get responsive bottom position for content
  double? _getContentBottomPosition(double screenHeight, double safeAreaBottom) {
    if (_currentPage != 1) {
      // Slides 1 & 3 positioned from bottom
      return safeAreaBottom + (screenHeight * 0.05); // 5% from safe area bottom
    }
    return null; // Slide 2 positioned from top
  }

  // Helper method to build responsive heading
  Widget _buildHeading(double screenWidth) {
    final headingStyle = TextStyle(
      fontSize: screenWidth * 0.065, // Responsive font size (6.5% of screen width)
      fontWeight: FontWeight.w700,
      fontFamily: 'Inter',
    );

    switch (_currentPage) {
      case 0:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: headingStyle.copyWith(color: Colors.black),
            children: [
              const TextSpan(text: 'Mabuhay, '),
              TextSpan(
                text: 'Explorer!',
                style: TextStyle(color: Colors.blue[900]),
              ),
            ],
          ),
        );
      case 1:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: headingStyle.copyWith(color: Colors.blue[900]),
            children: [
              const TextSpan(text: 'Find '),
              TextSpan(
                text: 'your way!',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      case 2:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: headingStyle.copyWith(color: Colors.black),
            children: [
              const TextSpan(text: 'Your '),
              TextSpan(
                text: 'Travel Buddy',
                style: TextStyle(color: Colors.blue[900]),
              ),
              const TextSpan(text: ' is Here!'),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}