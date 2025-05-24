/* Authored by: Maria Curly Ann Lumibao
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-003] ONBOARDING
Description: This is a page design for introducing users to the gala app, it includes tutorials 
on how to navigate the app.
*/

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
    "Your journey begins here. Let’s explore the best cafes, restaurants, and parks in Camarines Sur!",
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
    return Scaffold(
      body: Stack(
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
              return Image.asset(
                bgImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height:
                    MediaQuery.of(context).size.height, // FULL SCREEN HEIGHT
              );
            },
          ),

          // 2. Overlay container (text + buttons), position absolutely over image with transparent background
          Positioned(
            top: _currentPage == 1 ? 80 : null, // Slide 2 at top:60
            bottom:
                _currentPage != 1
                    ? 60
                    : null, // Slides 1 & 3 above bottom by 60
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.only(
                top:
                    _currentPage == 1
                        ? 5
                        : 0, // slide 2 has small top padding, others none
              ),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Heading
                    _currentPage == 0
                        ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: 'Mabuhay, '),
                              TextSpan(
                                text: 'Explorer!',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                            ],
                          ),
                        )
                        : _currentPage == 1
                        ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.blue[900],
                            ),
                            children: [
                              TextSpan(text: 'Find '),
                              TextSpan(
                                text: 'your way!',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        )
                        : _currentPage == 2
                        ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: 'Your '),
                              TextSpan(
                                text: 'Travel Buddy',
                                style: TextStyle(color: Colors.blue[900]),
                              ),
                              TextSpan(text: ' is Here!'),
                            ],
                          ),
                        )
                        : Container(),

                    const SizedBox(height: 16),

                    // Body text
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 290),
                      child: Text(
                        onboardingTexts[_currentPage],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(onboardingTexts.length, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 60),

                    // Buttons row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _skip,
                            child: const Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFF5F5F5),
                              side: BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              shadowColor: Colors.black.withOpacity(0.8),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                  '/set_location',
                                );
                              } else {
                                _nextPage();
                              }
                            },
                            child: Text(
                              _currentPage == onboardingTexts.length - 1
                                  ? "Done"
                                  : "Next",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),
        ],
      ),
    );
  }
}
