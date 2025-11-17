// NOTE: For a real application, you must configure your pubspec.yaml with:
// dependencies:
//   flutter:
//     sdk: flutter
//   flutter_map: ^6.1.0
//   latlong2: ^0.9.0
//   geolocator: ^11.0.0
//   http: ^1.2.1
//
// If you intended to use the official AWS client, you must use the Amplify Flutter
// packages: amplify_flutter. As of the latest updates, Geo features are typically accessed
// via the main Amplify SDK or custom integrations, as a dedicated 'amplify_geo' plugin
// is not available on pub.dev. The mock code below bypasses this by making direct HTTP
// calls, which is NOT secure for production.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- AWS CONFIGURATION PLACEHOLDERS ---
// IMPORTANT: In a production app, use AWS Amplify (amplify_flutter) for secure SigV4 signing,
// not hardcoded API keys or unauthenticated access, which is why the code below is mocked.
const String _AWS_REGION = 'us-east-1';
const String _MAP_NAME = 'MyAwsMap';
const String _PLACE_INDEX = 'MyAwsPlaceIndex';
const String _ROUTE_CALCULATOR = 'MyAwsRouteCalculator';

// Amazon Location Service Map Tile URL (Mock Structure)
// Note: Actual AWS Location tiles require SigV4 authentication via Amplify.
// This URL is a placeholder and will likely fail without proper authentication.
const String _TILE_URL =
    'https://maps.geo.$_AWS_REGION.amazonaws.com/maps/v0/maps/$_MAP_NAME/tiles/{z}/{x}/{y}';

void main() {
  runApp(const LocationApp());
}

class LocationApp extends StatelessWidget {
  const LocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AWS Geo Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Coordinates (San Francisco as default center)
  LatLng _mapCenter = const LatLng(37.7749, -122.4194);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // State for search results and route
  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  String _statusMessage = 'Ready to search!';

  // --- MOCK LOCATION (Replaced by geolocator in a real app) ---
  // In a real app, use the geolocator package to get the current location.
  Future<void> _getCurrentLocation() async {
    setState(() {
      _statusMessage = 'Simulating getting current location...';
    });
    // This is where geolocator or an AWS Tracker call would go.
    // Simulating a result after a short delay
    await Future.delayed(const Duration(seconds: 1));
    const currentLocation = LatLng(37.7874, -122.4048); // SF Transamerica Pyramid
    _updateMap(currentLocation, 'Current Location');
    setState(() {
      _mapCenter = currentLocation;
      _statusMessage = 'Location Found!';
    });
    _mapController.move(_mapCenter, 14.0);
  }

  // --- AWS LOCATION SERVICE: Search/Geocode ---
  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _statusMessage = 'Searching for "$query"...';
      _markers = [];
      _routePoints = [];
    });

    // MOCK: Replace this with an authenticated AWS call (e.g., via Amplify or AWS SDK).
    final url =
        'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search?text=$query';

    try {
      // NOTE: Actual AWS calls require SigV4 signing via Amplify, not a direct http request.
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // --- MOCK RESPONSE HANDLING (Since we can't make a real AWS call) ---
        // In a real response, parse the GeoJSON data returned by Amplify Geo.
        final mockResults = [
          {'lat': 37.8086, 'lng': -122.4098, 'name': 'Pier 39'},
          {'lat': 37.7858, 'lng': -122.4064, 'name': 'Museum of Modern Art'},
        ];
        
        if (mockResults.isNotEmpty) {
          final firstResult = LatLng(mockResults.first['lat'] as double, mockResults.first['lng'] as double);
          _updateMap(firstResult, mockResults.first['name'] as String);
          setState(() {
            _statusMessage = 'Found ${mockResults.length} results.';
          });
          _mapController.move(firstResult, 14.0);
        } else {
          setState(() {
            _statusMessage = 'No places found.';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Search failed (Mocked: Status ${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error during search: $e';
      });
    }
  }

  // --- AWS LOCATION SERVICE: Route Calculation ---
  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    setState(() {
      _statusMessage = 'Calculating route...';
      _routePoints = [];
    });

    // MOCK: Replace this with an authenticated AWS call (e.g., via Amplify or AWS SDK).
    // Departure and Destination are [Longitude, Latitude] in AWS
    final startLonLat = '${start.longitude},${start.latitude}';
    final endLonLat = '${end.longitude},${end.latitude}';
    
    final url =
        'https://routes.geo.$_AWS_REGION.amazonaws.com/routes/v0/calculators/$_ROUTE_CALCULATOR/calculateRoute?DeparturePosition=$startLonLat&DestinationPosition=$endLonLat';

    try {
      // NOTE: Actual AWS calls require SigV4 signing via Amplify.
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // --- MOCK ROUTE HANDLING (Simulating a simple straight line route) ---
        // In a real response, parse the line geometry from the GeoJSON returned by AWS.
        
        final mockRoute = [
          start,
          // A middle point to make it look like a route
          LatLng((start.latitude + end.latitude) / 2, (start.longitude + end.longitude) / 2), 
          end
        ];

        setState(() {
          _routePoints = mockRoute;
          _statusMessage = 'Route calculated! (Total points: ${_routePoints.length})';
        });
      } else {
        setState(() {
          _statusMessage = 'Route calculation failed (Mocked: Status ${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error calculating route: $e';
      });
    }
  }

  void _updateMap(LatLng location, String title) {
    setState(() {
      _markers = [
        Marker(
          width: 80.0,
          height: 80.0,
          point: location,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 48.0,
          ),
        ),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Geo Navigator'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Get Current Location',
          ),
          IconButton(
            icon: const Icon(Icons.alt_route),
            onPressed: () => _calculateRoute(_mapCenter, const LatLng(37.8272, -122.4233)), // Center to Alcatraz
            tooltip: 'Find Route to Alcatraz (Mock)',
          ),
        ],
      ),
      body: Stack(
        children: [
          // --- Map Display (MapLibre/Amazon Location Service) ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 12.0,
              onTap: (tapPosition, latLng) {
                 _updateMap(latLng, 'Selected Point');
                 setState(() {
                    _statusMessage = 'Tapped: ${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
                 });
              },
            ),
            children: [
              TileLayer(
                // This is the core connection to Amazon Location Service map tiles.
                // In a real app, this URL must be dynamically generated and authenticated with SigV4 credentials via Amplify.
                urlTemplate: _TILE_URL, 
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 5.0,
                    color: Colors.indigo,
                  ),
                ],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // --- Search Bar ---
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search place (e.g., Starbucks, market)',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.blueGrey),
                      onPressed: () => _searchPlace(_searchController.text),
                    ),
                  ),
                  onSubmitted: _searchPlace,
                ),
              ),
            ),
          ),
          
          // --- Status Message/Footer ---
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // --- Manual Attribution Placement (since TileLayer parameter was removed) ---
          Positioned(
            bottom: 5,
            right: 5,
            child: Text(
              'Map data: AWS Location Service',
              style: TextStyle(color: Colors.black54, fontSize: 10),
            ),
          )
        ],
      ),
    );
  }
}