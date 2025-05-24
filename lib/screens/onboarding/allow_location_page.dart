import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'success_page.dart';

class AllowLocationPage extends StatefulWidget {
  const AllowLocationPage({Key? key}) : super(key: key);

  @override
  State<AllowLocationPage> createState() => _AllowLocationPageState();
}

class _AllowLocationPageState extends State<AllowLocationPage> {
  Future<void> _checkLocationPermissionAndGetPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Location services are disabled.");
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Location permission permanently denied.");
      return;
    }

    // Permissions granted, get location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationString = "${position.latitude}, ${position.longitude}";

      print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

      _showSnackBar("Location: $locationString");

      // Navigate to success page with the location string
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => LocationConfirmedPage(location: locationString),
          ),
        );
      }
    } catch (e) {
      _showSnackBar("Failed to get location: $e");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return CustomLocationPopup(
          onAllowPressed: () async {
            Navigator.pop(context);
            await _checkLocationPermissionAndGetPosition();
          },
          onDontAllowPressed: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

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
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Allow Location',
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
              top: MediaQuery.of(context).size.height * 0.41,
              left: 60,
              right: 60,
              child: Text(
                'Grant location access for accurate search results and navigation.',
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

            // Allow Permission Button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.51,
              left: 73,
              right: 73,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B55A0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(56),
                  ),
                  elevation: 3,
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: _showPermissionDialog,
                child: const Text(
                  'Allow Permission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
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

class CustomLocationPopup extends StatelessWidget {
  final VoidCallback onDontAllowPressed;
  final Future<void> Function() onAllowPressed;

  const CustomLocationPopup({
    Key? key,
    required this.onAllowPressed,
    required this.onDontAllowPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        width: 325,
        height: 211,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Stack(
          children: [
            // Horizontal line at bottom
            Positioned(
              left: 0,
              top: 163,
              child: Container(
                width: 325,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFC8CDD0)),
                  ),
                ),
              ),
            ),

            // Vertical line
            Positioned(
              left: 163,
              top: 163,
              child: Transform.rotate(
                angle: 1.57,
                child: const Divider(
                  color: Color(0xFFD4D4D4),
                  thickness: 1,
                  height: 48,
                ),
              ),
            ),

            // Title Text
            const Positioned(
              left: 31,
              top: 22,
              right: 31,
              child: Text(
                'Allow “Gala” to access your location while you are using the app?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.32,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Description
            const Positioned(
              left: 25,
              top: 105,
              right: 25,
              child: Text(
                'We need access to your location to show you relevant search results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                  letterSpacing: -0.32,
                ),
              ),
            ),

            // Allow Button
            Positioned(
              left: 180,
              top: 165,
              child: TextButton(
                onPressed: () => onAllowPressed(),
                child: const SizedBox(
                  width: 90,
                  child: Text(
                    'Allow',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1461A0),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ),
            ),

            // Don't Allow Button
            Positioned(
              left: 10,
              top: 160,
              child: TextButton(
                onPressed: onDontAllowPressed,
                child: const SizedBox(
                  width: 144,
                  height: 39,
                  child: Center(
                    child: Text(
                      'Don’t Allow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1461A0),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.31,
                        letterSpacing: -0.32,
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
