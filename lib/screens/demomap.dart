// demomap.dart (Keep this file separate as it was before)

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- MOCK AWS CONFIGURATION PLACEHOLDERS ---
const String _AWS_REGION = 'ap-southeast-2';
const String _API_KEY = 'v1.public.eyJqdGkiOiJmODM2YmQ1MC1kODM5LTQyYTEtYWI3ZS1iZjRiYjg1ODM1MzcifWHOwa4-W2YE3a_6zUNhYPytUp7pbcab_KIEHqEmn3mhkWJ8ibuYhKOOSAjMbMbZRhinGFPmxHxIICcB7AeBES8-WlNQEGWoy-46sMrYv2nS9mJQ88h2E8qZOixsMH7FaYSD9q0cUE18LioPoyoJWHcHOys0ofZe1GcFE1eesYWDT7oBfv-4vat18l3DxEG8Ff6H_xXdm5Eva4pgBReSjSIu1qOm6ptG3LFRhHVbn9de2S6CyFpT623mmwIF8fjrBkDfjULj0gzm7nFhn20PAVYaAHJ4BaRTxXlZosHceOMt_TsNWLb7uf1MQIsmnB7qt1AFk2mhcHVQQBaDCZkeYY4.ZTA2OTdiZTItNzgyYy00YWI5LWFmODQtZjdkYmJkODNkMmFh';
const String _MAP_NAME = 'MyAppMap';
const String _PLACE_INDEX = 'MyAwsPlaceIndex';
const String _ROUTE_CALCULATOR = 'MyAwsRouteCalculator';
const String _TILE_URL =
    'https://maps.geo.$_AWS_REGION.amazonaws.com/maps/v0/maps/$_MAP_NAME/tiles/{z}/{x}/{y}?key=$_API_KEY';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _mapCenter = const LatLng(37.7749, -122.4194);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  String _statusMessage = 'Ready to search!';

  Future<void> _getCurrentLocation() async {
    setState(() {
      _statusMessage = 'Getting location...';
    });

    // NOTE: In a real app, use the 'geolocator' package here.
    // For this demo, we simulate a starting location (e.g., Naga City or SF).
    await Future.delayed(const Duration(seconds: 1));
    const currentLocation = LatLng(37.7874, -122.4048); // Simulating SF for demo consistency

    if (!mounted) return;

    _updateMap(currentLocation, 'Current Location');
    setState(() {
      _mapCenter = currentLocation;
      _statusMessage = 'Location Found!';
    });

    // Safe movement of map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_mapCenter, 14.0);
    });
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _statusMessage = 'Searching for "$query"...';
      _markers = [];
      _routePoints = [];
    });

    final url = Uri.parse(
        'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/text?key=$_API_KEY');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Text': query,
          'MaxResults': 5,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['Results'] as List;

        if (results.isNotEmpty) {
          // AWS returns [Longitude, Latitude]
          final point = results[0]['Place']['Geometry']['Point'];
          final firstResult = LatLng(point[1], point[0]);
          final label = results[0]['Place']['Label'] ?? query;

          _updateMap(firstResult, label);
          setState(() {
            _statusMessage = 'Found: $label';
          });
          _mapController.move(firstResult, 14.0);
        } else {
          setState(() {
            _statusMessage = 'No places found.';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Search Failed: ${response.statusCode} ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    setState(() {
      _statusMessage = 'Calculating route...';
      _routePoints = [];
    });

    // AWS Location Service Route Endpoint (POST)
    final url = Uri.parse(
        'https://routes.geo.$_AWS_REGION.amazonaws.com/routes/v0/calculators/$_ROUTE_CALCULATOR/calculate/route?key=$_API_KEY');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // AWS expects [Longitude, Latitude]
          'DeparturePosition': [start.longitude, start.latitude],
          'DestinationPosition': [end.longitude, end.latitude],
          'IncludeLegGeometry': true, // Required to get the path line
          'TravelMode': 'Car',
          'DistanceUnit': 'Kilometers'
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse the geometry line string
        final legs = data['Legs'] as List;
        if (legs.isNotEmpty) {
          final geometry = legs[0]['Geometry']['LineString'] as List;

          // Convert AWS [Lon, Lat] list to Flutter [LatLng] list
          final List<LatLng> path = geometry.map((coord) {
            return LatLng(coord[1], coord[0]);
          }).toList();

          setState(() {
            _routePoints = path;
            _statusMessage = 'Route found! ${data['Summary']['Distance'].toStringAsFixed(1)} km';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Route Failed: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error: $e';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Geo Navigator'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Get Current Location',
          ),
          IconButton(
            icon: const Icon(Icons.alt_route),
            // Example route: Current Center -> Fixed Point (e.g., Coit Tower)
            onPressed: () => _calculateRoute(_mapCenter, const LatLng(37.8024, -122.4058)),
            tooltip: 'Route Demo',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 12.0,
              onTap: (tapPosition, latLng) {
                _updateMap(latLng, 'Selected Point');
                print("Tapped: ${latLng.latitude}, ${latLng.longitude}");
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _TILE_URL,
                userAgentPackageName: 'com.example.app',
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
                    hintText: 'Search place (e.g., Starbucks)',
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
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}