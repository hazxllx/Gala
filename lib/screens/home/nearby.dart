import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // Required for the math logic

// --- CONFIG ---
const String _AWS_REGION = 'ap-southeast-1';
const String _PLACE_INDEX = 'MyPlaceIndex';
const String _API_KEY =
    'v1.public.eyJqdGkiOiJmNjYzMGVlYi0xNzA2LTQxNDItYWQyYy1jYzMzNTc0NGM0ZmIifQg38P6cE6L4sb71GcGuteb40sqtqQlariMJDviQkWwltWUwfUEc8rSPmUo3vtOHGEL0U0z9vpQBeVbdNfZZ886jGXhNY9Kc6xdNykSCuqleZ2gVOgb6YxLay0F9wTr2d9Uzv5wawpQEfhucGX8y9trnEAm68wSvCorCGAFlPMOsW2MAzEEMMsKpFMZ6Cf3rTO_v-_YHLniGzuWRiID0tY_d2pJBo9egY6QeYFNI-srp2gMRlXoqzHxbBoCNVDSxwSMH7oEgAIvEso8-Cb3iQ-puWGftX8-kQ3uoEUkHXPiTlGksY72Hi9fkUkC20KeOvCX-RZ9RL2PIb_xjSEn89Ec.MzRjYzZmZGUtZmY3NC00NDZiLWJiMTktNTc4YjUxYTFlOGZi';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  late final WebViewController _webViewController;
  Position? _currentPosition;
  bool _isLoading = false;

  // Filters
  final List<String> _categories = [
    "Coffee",
    "Park",
    "Hotel",
    "Bank",
    "Restaurant",
    "Gas Station",
  ];
  String _selectedCategory = "Coffee";
  double _radiusKm = 2.0;

  // UI State
  Map<String, dynamic>? _selectedPlace;
  bool _isCardVisible = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..addJavaScriptChannel(
            'PlaceSelected',
            onMessageReceived: (JavaScriptMessage message) {
              final placeData = jsonDecode(message.message);
              _onPlaceTapped(placeData);
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                print("Map Loaded. Getting Location...");
                _getCurrentLocation();
              },
              onWebResourceError: (error) {
                _showError("Map Error: ${error.description}");
              },
            ),
          )
          ..loadFlutterAsset('assets/aws_map.html');
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permissions are denied.");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);

      // Pass location to Map
      _webViewController.runJavaScript(
        'updateStartLocation(${position.latitude}, ${position.longitude})',
      );

      // Start Search
      _searchNearbyPlaces();
    } catch (e) {
      _showError("Loc Error: $e");
    }
  }

  Future<void> _searchNearbyPlaces() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/text?key=$_API_KEY',
    );

    try {
      // 1. Calculate Bounding Box
      double lat = _currentPosition!.latitude;
      double lon = _currentPosition!.longitude;

      // 1 degree lat ~ 111km
      // 1 degree lon ~ 111km * cos(lat)
      double latOffset = _radiusKm / 111.0;
      double lonOffset = _radiusKm / (111.0 * cos(lat * (pi / 180.0)));

      List<double> bbox = [
        lon - lonOffset, // min Lon
        lat - latOffset, // min Lat
        lon + lonOffset, // max Lon
        lat + latOffset, // max Lat
      ];

      final body = jsonEncode({
        "Text": _selectedCategory,
        "FilterBBox": bbox,
        "MaxResults": 50,
        "FilterCountries": ["PHL"],
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final results = data['Results'] as List;

  final List<Map<String, dynamic>> validPlaces = [];

  // --- NEW LOGIC: Use Index for Ranking ---
  int index = 0; 

  for (var item in results) {
    final place = item['Place'];
    final geom = place['Geometry']['Point'];
    final pLat = geom[1];
    final pLon = geom[0];

    final distMeters = Geolocator.distanceBetween(lat, lon, pLat, pLon);

    if (distMeters <= (_radiusKm * 1000)) {
      validPlaces.add({
        'label': place['Label'],
        'lat': pLat,
        'lon': pLon,
        'dist': distMeters,
        'categories': place['Categories'] ?? [],
        'rank': index, // <--- 0, 1, 2, 3...
      });
      index++;
    }
  }
  // ----------------------------------------

  final jsonString = jsonEncode(validPlaces);
  _webViewController.runJavaScript('updatePlaces(\'$jsonString\')');
}
    } catch (e) {
      _showError("Network Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _onPlaceTapped(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
      _isCardVisible = true;
    });
  }

  void _closeCard() {
    setState(() {
      _isCardVisible = false;
      _selectedPlace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          WebViewWidget(controller: _webViewController),

          // Top Controls
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children:
                        _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (val) {
                                if (val) {
                                  setState(() {
                                    _selectedCategory = cat;
                                    _closeCard();
                                  });
                                  _searchNearbyPlaces();
                                }
                              },
                              selectedColor: Colors.redAccent,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("Range: ${_radiusKm.toStringAsFixed(1)} km"),
                      Expanded(
                        child: Slider(
                          value: _radiusKm,
                          min: 0.5,
                          max: 10.0,
                          divisions: 19,
                          activeColor: Colors.redAccent,
                          onChanged: (val) => setState(() => _radiusKm = val),
                          onChangeEnd: (val) => _searchNearbyPlaces(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading
          if (_isLoading)
            const Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              ),
            ),

          // Card (Simplified for brevity)
          if (_isCardVisible && _selectedPlace != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 200,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlace!['label'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${(_selectedPlace!['dist'] as double).toStringAsFixed(0)} meters away",
                    ),
                    Spacer(),
                    ElevatedButton(onPressed: _closeCard, child: Text("Close")),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
