import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// --- CONFIG ---
const String _AWS_REGION = 'ap-southeast-1';
const String _PLACE_INDEX = 'MyPlaceIndex';
const String _API_KEY =
    'v1.public.eyJqdGkiOiJmNjYzMGVlYi0xNzA2LTQxNDItYWQyYy1jYzMzNTc0NGM0ZmIifQg38P6cE6L4sb71GcGuteb40sqtqQlariMJDviQkWwltWUwfUEc8rSPmUo3vtOHGEL0U0z9vpQBeVbdNfZZ886jGXhNY9Kc6xdNykSCuqleZ2gVOgb6YxLay0F9wTr2d9Uzv5wawpQEfhucGX8y9trnEAm68wSvCorCGAFlPMOsW2MAzEEMMsKpFMZ6Cf3rTO_v-_YHLniGzuWRiID0tY_d2pJBo9egY6QeYFNI-srp2gMRlXoqzHxbBoCNVDSxwSMH7oEgAIvEso8-Cb3iQ-puWGftX8-kQ3uoEUkHXPiTlGksY72Hi9fkUkC20KeOvCX-RZ9RL2PIb_xjSEn89Ec.MzRjYzZmZGUtZmY3NC00NDZiLWJiMTktNTc4YjUxYTFlOGZi';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late final WebViewController _webViewController;
  
  // Destination: Arco Diez Cafe
  final LatLng _destination = LatLng(13.6608, 123.2624);
  
  // State
  Position? _currentPosition;
  String _currentAddress = "Locating...";
  double? _routeDistance;
  double? _routeDuration;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _getCurrentLocation();
          },
        ),
      )
      ..loadFlutterAsset('assets/aws_map.html');
  }

  // --- LOCATION & ROUTING ---

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() => _currentPosition = position);

      // 1. Set Start on Map
      _webViewController.runJavaScript(
        'updateStartLocation(${position.latitude}, ${position.longitude})',
      );

      // 2. Set Destination on Map
      _webViewController.runJavaScript(
        'updateDestination(${_destination.latitude}, ${_destination.longitude})',
      );

      // 3. Get Address text
      _getAwsAddress(LatLng(position.latitude, position.longitude));

      // 4. Calculate Route
      _calculateRoute(
        LatLng(position.latitude, position.longitude), 
        _destination
      );

    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  Future<void> _getAwsAddress(LatLng pos) async {
    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/position?key=$_API_KEY',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Position": [pos.longitude, pos.latitude], "MaxResults": 1}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Results'].isNotEmpty) {
          setState(() {
            _currentAddress = data['Results'][0]['Place']['Label'];
          });
        }
      }
    } catch (e) {
      debugPrint("Reverse Geocode Error: $e");
    }
  }

  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          // Draw Route Line on Map
          final geometry = jsonEncode(route['geometry']['coordinates']);
          _webViewController.runJavaScript('drawRoute($geometry)');

          setState(() {
            _routeDistance = route['distance']?.toDouble();
            // Multiply duration by 2 as requested
            _routeDuration = (route['duration']?.toDouble() ?? 0) * 2;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Routing Error: $e");
    }
  }

  // --- HELPERS ---
  String _formatDuration(double? seconds) {
    if (seconds == null) return "...";
    final min = (seconds / 60).round();
    if (min < 60) return "$min min";
    final hr = (min / 60).floor();
    final remMin = min % 60;
    return "${hr}h ${remMin}m";
  }

  String _formatDistance(double? meters) {
    if (meters == null) return "...";
    if (meters < 1000) return "${meters.round()} m";
    return "${(meters / 1000).toStringAsFixed(1)} km";
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top: Map + Back Button
            SizedBox(
              height: screenHeight * 0.45, // Slightly taller map
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  
                  // Back Button
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // Loading Indicator inside map
                  if (_isLoading)
                    Container(
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      child: Text(
                        'Arco Diez Cafe Location',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // Current Location Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                      child: _locationInfoCard(
                        title: 'Current location',
                        subtitle: _currentAddress,
                        icon: Icons.my_location,
                        bgColor: const Color(0xFF0B55A0),
                        iconBgColor: Colors.white,
                        textColor: Colors.white,
                        iconColor: const Color(0xFF0B55A0),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Destination Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                      child: _locationInfoCard(
                        title: 'Destination',
                        subtitle: 'Arco Diez, Km. 10 Pacol Rd, Naga, 4400',
                        icon: Icons.location_on,
                        bgColor: const Color.fromARGB(255, 6, 62, 118),
                        iconBgColor: Colors.white,
                        textColor: Colors.white,
                        iconColor: const Color.fromARGB(255, 6, 62, 118),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Directions Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Directions',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // Placeholder for "View more" logic if needed
                          Text(
                            'View more...',
                            style: TextStyle(
                              color: const Color(0xFF025582),
                              fontSize: 15,
                              fontFamily: 'Work Sans',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Route Summary Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 26,
                                    color: Color(0xFF3D4C5B), // Greyish color
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Travel',
                                      style: const TextStyle(
                                        color: Color(0xFF141414),
                                        fontSize: 14.8,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${_formatDuration(_routeDuration)}, ${_formatDistance(_routeDistance)}',
                                      style: const TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Fastest route, usual traffic',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Fares Section (Static/Placeholder)
                    const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 8, top: 6),
                      child: Text(
                        'Estimated Public Transit Fares',
                        style: TextStyle(
                          color: Color(0xFF141414),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.directions_bus, size: 22, color: Colors.black54),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tricycle / Jeepney',
                                      style: TextStyle(
                                        color: Color(0xFF141414),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Regular: P20   |   PWD & Student: P15',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Location Card Widget
  Widget _locationInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.90),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      fontSize: 13.7,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple LatLng class for local usage
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}