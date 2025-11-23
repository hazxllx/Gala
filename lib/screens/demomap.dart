import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// --- AWS CONFIGURATION ---
const String _AWS_REGION = 'ap-southeast-1';
const String _PLACE_INDEX = 'MyPlaceIndex';
const String _API_KEY =
    'v1.public.eyJqdGkiOiJmNjYzMGVlYi0xNzA2LTQxNDItYWQyYy1jYzMzNTc0NGM0ZmIifQg38P6cE6L4sb71GcGuteb40sqtqQlariMJDviQkWwltWUwfUEc8rSPmUo3vtOHGEL0U0z9vpQBeVbdNfZZ886jGXhNY9Kc6xdNykSCuqleZ2gVOgb6YxLay0F9wTr2d9Uzv5wawpQEfhucGX8y9trnEAm68wSvCorCGAFlPMOsW2MAzEEMMsKpFMZ6Cf3rTO_v-_YHLniGzuWRiID0tY_d2pJBo9egY6QeYFNI-srp2gMRlXoqzHxbBoCNVDSxwSMH7oEgAIvEso8-Cb3iQ-puWGftX8-kQ3uoEUkHXPiTlGksY72Hi9fkUkC20KeOvCX-RZ9RL2PIb_xjSEn89Ec.MzRjYzZmZGUtZmY3NC00NDZiLWJiMTktNTc4YjUxYTFlOGZi';

// Helper classes used for routing data
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class RouteOption {
  final List<dynamic> coordinates; // List of [lng, lat] arrays
  final double distance; // in meters
  final double duration; // in seconds
  final String description;

  RouteOption({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.description,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final WebViewController _webViewController;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  LatLng? _startPos;
  LatLng? _destPos;

  bool _isLoading = true;
  String _statusMessage = "";

  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingStart = false;

  // --- ROUTING STATE ---
  List<RouteOption> _routeOptions = [];
  int _selectedRouteIndex = 0;
  double? _routeDistance;
  double? _routeDuration;

  @override
  void initState() {
    super.initState();

    final WebViewController controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              _getCurrentLocation();
            }
          },
        ),
      );

    controller.loadFlutterAsset('assets/aws_map.html');
    _webViewController = controller;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _startController.dispose();
    _destController.dispose();
    super.dispose();
  }

  // --- FORMATTING HELPERS ---
  String _formatDuration(double seconds) {
    if (seconds < 60) {
      return '${seconds.toInt()} sec';
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).round();
      return '$minutes min';
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).round();
      if (minutes == 0) {
        return '$hours hr';
      }
      return '$hours hr $minutes min';
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  double _calculateRealisticDuration(
    double distanceMeters,
    double osrmDurationSeconds,
  ) {
    if (distanceMeters <= 0) return osrmDurationSeconds;

    final distanceKm = distanceMeters / 1000;
    double averageSpeedKmh;

    if (distanceKm < 1) {
      averageSpeedKmh = 18;
    } else if (distanceKm < 3) {
      averageSpeedKmh = 22;
    } else if (distanceKm < 10) {
      averageSpeedKmh = 30;
    } else {
      averageSpeedKmh = 40;
    }

    final realisticDurationSeconds =
        distanceMeters / (averageSpeedKmh * 0.2778);
    final finalDuration =
        realisticDurationSeconds > osrmDurationSeconds
            ? realisticDurationSeconds
            : osrmDurationSeconds * 1.3;

    return finalDuration;
  }

  // --- LOCATION LOGIC ---

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Locating you...";
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );

      _startPos = LatLng(position.latitude, position.longitude);

      String awsAddress = await _getAwsAddressFromLatLng(_startPos!);
      _startController.text = awsAddress;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "";
        });

        _webViewController.runJavaScript(
          'updateStartLocation(${position.latitude}, ${position.longitude})',
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- AWS API HELPERS ---

  Future<String> _getAwsAddressFromLatLng(LatLng pos) async {
    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/position?key=$_API_KEY',
    );

    try {
      final body = json.encode({
        "Position": [pos.longitude, pos.latitude],
        "MaxResults": 1,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Results'].isNotEmpty) {
          return data['Results'][0]['Place']['Label'];
        }
      }
    } catch (e) {
      debugPrint("AWS Reverse Geocode Exception: $e");
    }
    return "Current Location";
  }

  void _onSearchChanged(String query, bool isStartField) {
    _isSearchingStart = isStartField;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length > 2) {
        _fetchSuggestionsAWS(query);
      } else {
        setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _fetchSuggestionsAWS(String query) async {
    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/text?key=$_API_KEY',
    );

    // Naga City Bounding Box for filtering search results
    // Lon, Lat, Lon, Lat (SW Corner to NE Corner)
    final nagaCityBBox = [123.1000, 13.5500, 123.2800, 13.7000];

    try {
      final body = json.encode({
        "Text": query,
        "MaxResults": 15,
        "FilterBBox": nagaCityBBox,
        "FilterCountries": ["PHL"],
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;

        final suggestions =
            results.map((item) {
              final place = item['Place'];
              return {
                'display_name': place['Label'],
                'lat': place['Geometry']['Point'][1],
                'lon': place['Geometry']['Point'][0],
              };
            }).toList();

        if (mounted) {
          setState(() {
            _suggestions = suggestions;
          });
        }
      } else {
        debugPrint("AWS Search Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching AWS suggestions: $e");
    }
  }

  void _selectSuggestion(dynamic suggestion) {
    final lat = suggestion['lat'];
    final lon = suggestion['lon'];
    final displayName = suggestion['display_name'];

    setState(() {
      if (_isSearchingStart) {
        // START changed
        _startController.text = displayName;
        _startPos = LatLng(lat, lon);
        _webViewController.runJavaScript('updateStartLocation($lat, $lon)');

        // Recalculate route if Destination is already set
        if (_destPos != null) {
          _calculateRoute(_startPos!, _destPos!);
        }
      } else {
        // DESTINATION changed
        _destController.text = displayName;
        _destPos = LatLng(lat, lon);
        _webViewController.runJavaScript('updateDestination($lat, $lon)');

        // Recalculate route if Start is already set
        if (_startPos != null) {
          _calculateRoute(_startPos!, _destPos!);
        }
      }
      _suggestions = [];
    });

    FocusScope.of(context).unfocus();
  }

  // --- ROUTING LOGIC ---

  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Calculating route...";
      _routeOptions = [];
      _routeDistance = null;
      _routeDuration = null;
    });

    // OSRM API call includes alternatives=true to get multiple routes
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson&alternatives=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final routes = data['routes'] as List;
          List<RouteOption> routeOptions = [];

          for (int i = 0; i < routes.length; i++) {
            final route = routes[i];
            final coordinates = route['geometry']['coordinates'] as List;

            final distance = route['distance']?.toDouble() ?? 0;
            final baseDuration = route['duration']?.toDouble() ?? 0;

            final adjustedDuration = _calculateRealisticDuration(
              distance,
              baseDuration,
            );

            String description =
                (i == 0) ? 'Fastest Route' : 'Alternative ${i}';

            routeOptions.add(
              RouteOption(
                coordinates: coordinates,
                distance: distance,
                duration: adjustedDuration,
                description: description,
              ),
            );
          }

          // Sort options by duration (fastest first)
          routeOptions.sort((a, b) => a.duration.compareTo(b.duration));

          // Set the primary route
          _selectRoute(0, routeOptions);
        } else {
          setState(() {
            _isLoading = false;
            _statusMessage = "Route not found.";
          });
          _webViewController.runJavaScript('drawRoute([])');
        }
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = "Routing Service Error: ${response.statusCode}";
        });
        _webViewController.runJavaScript('drawRoute([])');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Routing failed (OSRM): Check connection.";
      });
      _webViewController.runJavaScript('drawRoute([])');
    }
  }

  void _selectRoute(int index, [List<RouteOption>? options]) {
    final list = options ?? _routeOptions;

    if (index >= 0 && index < list.length) {
      final route = list[index];

      // Send coordinates to the HTML Map
      final jsonGeometry = json.encode(route.coordinates);
      _webViewController.runJavaScript('drawRoute($jsonGeometry)');

      setState(() {
        _routeOptions = list;
        _selectedRouteIndex = index;
        _routeDistance = route.distance;
        _routeDuration = route.duration;
        _isLoading = false;
        _statusMessage =
            "${_formatDistance(route.distance)} • ${_formatDuration(route.duration)}";
      });
    }
  }

  void _showRouteOptions() {
    if (_routeOptions.isEmpty) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final selectedColor = isDarkMode ? Colors.blue[700]! : Colors.blue[100]!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.route, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Select Route',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        color: textColor,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Route options list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _routeOptions.length,
                    itemBuilder: (context, index) {
                      final route = _routeOptions[index];
                      final isSelected = index == _selectedRouteIndex;

                      return InkWell(
                        onTap: () {
                          _selectRoute(index);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? selectedColor : cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.blue[600]!
                                      : (isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Route indicator
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue[600]
                                          : Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Route info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      route.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.route,
                                          size: 14,
                                          color: Colors.blue[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDistance(route.distance),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.orange[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDuration(route.duration),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Selected indicator
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue[600],
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _clearStart() {
    _startController.clear();
    setState(() {
      _startPos = null;
      // FIX 1: Clear the green marker by moving it off-screen
      _webViewController.runJavaScript('updateStartLocation(0, 0)');

      _suggestions = [];
      _routeOptions = [];
      _routeDistance = null;
      _routeDuration = null;
    });

    // FIX 2: Only clear route line and update status if a destination exists
    if (_destPos != null) {
      _webViewController.runJavaScript('drawRoute([])');
      setState(
        () => _statusMessage = "Destination set. Please select a new Start.",
      );
    } else {
      setState(() => _statusMessage = "Select Start and Destination.");
    }
  }

  void _clearMap() {
    _destController.clear();
    setState(() {
      _destPos = null;
      _statusMessage = "";
      _suggestions = [];
      _routeOptions = [];
      _routeDistance = null;
      _routeDuration = null;
    });

    // Clear route line and the Red Destination marker from HTML
    _webViewController.runJavaScript('clearRoute()');

    // If Start is still set, update status to prompt for new destination
    if (_startPos != null) {
      setState(
        () => _statusMessage = "Start set. Please select a new Destination.",
      );
    } else {
      setState(() => _statusMessage = "Select Start and Destination.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if distance/duration data is ready for display
    final isRouteInfoReady = _routeDistance != null && _routeDuration != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // --- START LOCATION INPUT ---
                        TextField(
                          controller: _startController,
                          onChanged: (val) => _onSearchChanged(val, true),
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.my_location,
                              color: Colors.green,
                            ),
                            labelText: "Start Location",
                            border: InputBorder.none,
                            isDense: true,
                            // Clear button for Start input
                            suffixIcon:
                                _startController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: _clearStart,
                                    )
                                    : null,
                          ),
                        ),
                        const Divider(),
                        // --- DESTINATION INPUT ---
                        TextField(
                          controller: _destController,
                          onChanged: (val) => _onSearchChanged(val, false),
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            labelText: "Where to?",
                            border: InputBorder.none,
                            isDense: true,
                            suffixIcon:
                                _destController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: _clearMap,
                                    )
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- SEARCH SUGGESTIONS LIST ---
                  if (_suggestions.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      color: Colors.white,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _suggestions[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.place,
                              size: 20,
                              color: Colors.grey,
                            ),
                            title: Text(
                              item['display_name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () => _selectSuggestion(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- ROUTE INFO CARD ---
          if (isRouteInfoReady)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          // Show Distance and Duration
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Route Options Button
                      if (_routeOptions.length > 1)
                        TextButton(
                          onPressed: _showRouteOptions,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white24,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            '${_routeOptions.length} Options',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom:
                isRouteInfoReady
                    ? 120
                    : 30, // Adjust height based on whether the route info is visible
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.gps_fixed, color: Colors.black),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
