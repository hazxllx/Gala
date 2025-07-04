import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Location services are disabled.");
      return;
    }

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

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Confirm it's not mocked/faked
      if (position.isMocked) {
        _showSnackBar("Fake/mock location detected. Please use a real device.");
        return;
      }

      String readableAddress = await _getAddressFromCoordinates(position);

      _showSnackBar("Location: $readableAddress");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LocationConfirmedPage(location: readableAddress),
          ),
        );
      }
    } catch (e) {
      _showSnackBar("Failed to get location: $e");
    }
  }

  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      }
    } catch (e) {
      print("Reverse geocoding failed: $e");
    }
    return "${position.latitude}, ${position.longitude}";
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/bg2.png",
              fit: BoxFit.cover,
            ),
          ),

          // Blue location icon
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.29,
            child: SizedBox(
              width: 180,
              height: 180,
              child: Image.asset("assets/allow_loc.png", fit: BoxFit.cover),
            ),
          ),

          // Heading
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Allow Location',
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

          // Subheading
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

          // Allow button
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
