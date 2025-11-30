import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';

// --- AWS CONFIGURATION ---
const String _AWS_REGION = 'ap-southeast-1';
const String _PLACE_INDEX = 'MyPlaceIndex';
const String _API_KEY =
    'v1.public.eyJqdGkiOiJmNjYzMGVlYi0xNzA2LTQxNDItYWQyYy1jYzMzNTc0NGM0ZmIifQg38P6cE6L4sb71GcGuteb40sqtqQlariMJDviQkWwltWUwfUEc8rSPmUo3vtOHGEL0U0z9vpQBeVbdNfZZ886jGXhNY9Kc6xdNykSCuqleZ2gVOgb6YxLay0F9wTr2d9Uzv5wawpQEfhucGX8y9trnEAm68wSvCorCGAFlPMOsW2MAzEEMMsKpFMZ6Cf3rTO_v-_YHLniGzuWRiID0tY_d2pJBo9egY6QeYFNI-srp2gMRlXoqzHxbBoCNVDSxwSMH7oEgAIvEso8-Cb3iQ-puWGftX8-kQ3uoEUkHXPiTlGksY72Hi9fkUkC20KeOvCX-RZ9RL2PIb_xjSEn89Ec.MzRjYzZmZGUtZmY3NC00NDZiLWJiMTktNTc4YjUxYTFlOGZi';

// Helper classes
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class RouteOption {
  final List<dynamic> coordinates;
  final double distance;
  final double duration;
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

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final WebViewController _webViewController;
  
  // Animation Controllers
  AnimationController? _slideInController;
  AnimationController? _pulseController;
  AnimationController? _shimmerController;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destController = TextEditingController();

  LatLng? _startPos;
  LatLng? _destPos;

  bool _isLoading = false;
  String _statusMessage = "";

  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearchingStart = false;

  List<RouteOption> _routeOptions = [];
  int _selectedRouteIndex = 0;
  double? _routeDistance;
  double? _routeDuration;

  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();

    // 1. Slide In Animation
    _slideInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 2. Breathing/Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // 3. Shimmer Animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    final WebViewController controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              _getCurrentLocation();
              _slideInController?.forward();
            }
          },
        ),
      );

    controller.loadFlutterAsset('assets/aws_map.html');
    _webViewController = controller;
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _debounce?.cancel();
    _slideInController?.dispose();
    _pulseController?.dispose();
    _shimmerController?.dispose();
    _startController.dispose();
    _destController.dispose();
    super.dispose();
  }

  // --- FORMATTING HELPERS ---
  String _formatDuration(double seconds) {
    if (seconds < 60) return '${seconds.toInt()} sec';
    if (seconds < 3600) return '${(seconds / 60).round()} min';
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).round();
    return minutes == 0 ? '$hours hr' : '$hours hr $minutes min';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  String _getEstimatedArrivalTime(double durationSeconds) {
    final now = DateTime.now();
    final arrival = now.add(Duration(seconds: durationSeconds.toInt()));
    final hour = arrival.hour > 12 ? arrival.hour - 12 : arrival.hour;
    final period = arrival.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${arrival.minute.toString().padLeft(2, '0')} $period';
  }

  // --- LOCATION LOGIC ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services', Icons.location_off_rounded);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission is required', Icons.location_disabled_rounded);
        return;
      }
    }

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) async {
      final newPos = LatLng(position.latitude, position.longitude);

      if (_startController.text.isEmpty || _startController.text == "Getting location...") {
        String address = await _getAwsAddressFromLatLng(newPos);
        if (mounted) _startController.text = address;
      }

      if (mounted) {
        setState(() => _startPos = newPos);
        _webViewController.runJavaScript(
          'updateStartLocation(${position.latitude}, ${position.longitude})',
        );
      }
    });
  }

  // --- SWAP LOGIC ---
  void _swapLocations() {
    setState(() {
      final tempText = _startController.text;
      _startController.text = _destController.text;
      _destController.text = tempText;

      final tempPos = _startPos;
      _startPos = _destPos;
      _destPos = tempPos;

      if (_startPos != null) {
        _webViewController.runJavaScript('updateStartLocation(${_startPos!.latitude}, ${_startPos!.longitude})');
      } else {
        _webViewController.runJavaScript('updateStartLocation(0, 0)');
      }

      if (_destPos != null) {
        _webViewController.runJavaScript('updateDestination(${_destPos!.latitude}, ${_destPos!.longitude})');
      } else {
        _webViewController.runJavaScript('updateDestination(0, 0)');
      }

      if (_startPos != null && _destPos != null) {
        _calculateRoute(_startPos!, _destPos!);
      } else {
        _clearRouteData();
      }
    });
  }

  void _clearRouteData() {
    _webViewController.runJavaScript('drawRoute([])');
    _routeOptions = [];
    _routeDistance = null;
    _routeDuration = null;
  }

  // --- AWS API ---
  Future<String> _getAwsAddressFromLatLng(LatLng pos) async {
    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/position?key=$_API_KEY',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"Position": [pos.longitude, pos.latitude], "MaxResults": 1}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Results'].isNotEmpty) return data['Results'][0]['Place']['Label'];
      }
    } catch (e) {
      debugPrint("AWS Reverse Geocode Error: $e");
    }
    return "Current Location";
  }

  void _onSearchChanged(String query, bool isStartField) {
    _isSearchingStart = isStartField;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
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
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "Text": query,
          "MaxResults": 8,
          "FilterBBox": [123.1000, 13.5500, 123.2800, 13.7000], // Naga City
          "FilterCountries": ["PHL"],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['Results'] as List;
        final suggestions = results.map((item) {
          final place = item['Place'];
          return {
            'display_name': place['Label'],
            'lat': place['Geometry']['Point'][1],
            'lon': place['Geometry']['Point'][0],
          };
        }).toList();

        if (mounted) setState(() => _suggestions = suggestions);
      }
    } catch (e) {
      debugPrint("AWS Suggestion Error: $e");
    }
  }

  void _selectSuggestion(dynamic suggestion) {
    final lat = suggestion['lat'];
    final lon = suggestion['lon'];
    final displayName = suggestion['display_name'];

    setState(() {
      if (_isSearchingStart) {
        _startController.text = displayName;
        _startPos = LatLng(lat, lon);
        _webViewController.runJavaScript('updateStartLocation($lat, $lon)');
        if (_destPos != null) _calculateRoute(_startPos!, _destPos!);
      } else {
        _destController.text = displayName;
        _destPos = LatLng(lat, lon);
        _webViewController.runJavaScript('updateDestination($lat, $lon)');
        if (_startPos != null) _calculateRoute(_startPos!, _destPos!);
      }
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();
  }

  // --- ROUTING ---
  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Finding optimal path...";
      _routeOptions = [];
      _routeDistance = null;
      _routeDuration = null;
    });

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
            final distance = route['distance']?.toDouble() ?? 0;
            
            double duration = route['duration']?.toDouble() ?? 0;
            duration = duration + 1000; 
            
            routeOptions.add(RouteOption(
              coordinates: route['geometry']['coordinates'] as List,
              distance: distance,
              duration: duration,
              description: i == 0 ? 'Fastest Route' : 'Alternative ${i + 1}',
            ));
          }
          routeOptions.sort((a, b) => a.duration.compareTo(b.duration));
          _selectRoute(0, routeOptions);
        } else {
          setState(() => _isLoading = false);
          _webViewController.runJavaScript('drawRoute([])');
          _showSnackBar('No accessible route found', Icons.error_outline);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Connection error. Please try again.', Icons.wifi_off_rounded);
    }
  }

  void _selectRoute(int index, [List<RouteOption>? options]) {
    final list = options ?? _routeOptions;
    if (index >= 0 && index < list.length) {
      final route = list[index];
      _webViewController.runJavaScript('drawRoute(${json.encode(route.coordinates)})');
      setState(() {
        _routeOptions = list;
        _selectedRouteIndex = index;
        _routeDistance = route.distance;
        _routeDuration = route.duration;
        _isLoading = false;
      });
    }
  }

  // --- UI COMPONENTS ---

  void _showRouteOptions() {
    if (_routeOptions.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildRouteSelectionSheet(),
    );
  }

  Widget _buildRouteSelectionSheet() {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.95), Colors.white.withOpacity(0.9)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -10))],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    Text(
                      'Select Route',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.grey[900], letterSpacing: -0.5),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF041D66).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('${_routeOptions.length} Options', style: const TextStyle(color: Color(0xFF041D66), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  shrinkWrap: true,
                  itemCount: _routeOptions.length,
                  itemBuilder: (context, index) {
                    final route = _routeOptions[index];
                    final isSelected = index == _selectedRouteIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF041D66) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(color: const Color(0xFF041D66).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))
                          else
                            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                        border: isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _selectRoute(index);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${index + 1}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600])),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(route.description, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[800])),
                                      const SizedBox(height: 4),
                                      Text('${_formatDuration(route.duration)} • ${_formatDistance(route.distance)}', style: TextStyle(fontSize: 14, color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500])),
                                    ],
                                  ),
                                ),
                                if (isSelected) Icon(Icons.check_circle, color: Colors.white, size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearStart() {
    _startController.clear();
    setState(() { _startPos = null; _suggestions = []; _clearRouteData(); });
    _webViewController.runJavaScript('updateStartLocation(0, 0)');
    _getCurrentLocation();
  }

  void _clearMap() {
    _destController.clear();
    setState(() { _destPos = null; _suggestions = []; _clearRouteData(); });
    _webViewController.runJavaScript('clearRoute()');
  }

  void _showSnackBar(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRouteReady = _routeDistance != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          
          // --- BACK ARROW & TOP INPUT CARD ---
          if (_slideInController != null)
            Positioned(
              top: 50, left: 20, right: 20,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _slideInController!, curve: Curves.elasticOut)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Arrow Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF041D66), size: 20),
                      ),
                    ),
                    
                    // Input Card
                    _buildGlassCard(
                      child: Column(
                        children: [
                          _buildInputRow(
                            controller: _startController,
                            icon: Icons.my_location_rounded,
                            iconColor: const Color(0xFF041D66),
                            hint: 'Your Location',
                            onChanged: (val) => _onSearchChanged(val, true),
                            onClear: _clearStart,
                          ),
                          Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 60, endIndent: 20),
                          _buildInputRow(
                            controller: _destController,
                            icon: Icons.location_on_rounded,
                            iconColor: const Color(0xFF4A90E2), 
                            hint: 'Where to?',
                            onChanged: (val) => _onSearchChanged(val, false),
                            onClear: _clearMap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // --- SUGGESTIONS LIST ---
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 250, left: 20, right: 20,
              child: _buildGlassCard(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 56),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF041D66).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.place, size: 18, color: Color(0xFF041D66)),
                        ),
                        title: Text(
                          item['display_name'], 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w500,
                            color: Colors.black87 // Explicitly set color for visibility
                          ),
                        ),
                        onTap: () => _selectSuggestion(item),
                      );
                    },
                  ),
                ),
              ),
            ),

          // --- ROUTE INFO CARD ---
          if (isRouteReady)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: _buildGlassCard(
                gradient: const LinearGradient(
                  colors: [Color(0xFF041D66), Color(0xFF0A2E85)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDuration(_routeDuration!), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text('ETA ${_getEstimatedArrivalTime(_routeDuration!)} • ${_formatDistance(_routeDistance!)}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      if (_routeOptions.length > 1)
                        GestureDetector(
                          onTap: _showRouteOptions,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Text('${_routeOptions.length}', style: const TextStyle(color: Color(0xFF041D66), fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Text('Routes', style: TextStyle(color: Color(0xFF041D66), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // --- GPS FAB ---
          Positioned(
            bottom: isRouteReady ? 180 : 40, right: 20,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: AnimatedBuilder(
                animation: _pulseController!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController!.value * 0.05),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF041D66), Color(0xFF0A2E85)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF041D66).withOpacity(0.4 + (_pulseController!.value * 0.2)), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- LOADING SKELETON ---
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Center(
                  child: _buildGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _shimmerController!,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    colors: [Colors.grey[300]!, Colors.white, Colors.grey[300]!],
                                    stops: [0.0, 0.5, 1.0],
                                    transform: GradientRotation(_shimmerController!.value * 6.28),
                                  ).createShader(bounds);
                                },
                                child: Container(width: 60, height: 60, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(_statusMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- COMMON WIDGETS ---
  Widget _buildGlassCard({required Widget child, Gradient? gradient}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.65)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15))],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    required Function(String) onChanged,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 16),
              decoration: InputDecoration.collapsed(hintText: hint, hintStyle: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w400)),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(onTap: onClear, child: Icon(Icons.close_rounded, size: 20, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
