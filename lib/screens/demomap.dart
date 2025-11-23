import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ====================================================
// 1. MAP CONFIGURATION ONLY
// ====================================================

const String _AWS_REGION = 'ap-southeast-2'; // Sydney
const String _MAP_NAME = 'MyAppMap'; // The resource name you confirmed in logs
const String _API_KEY = 'v1.public.eyJqdGkiOiJmODM2YmQ1MC1kODM5LTQyYTEtYWI3ZS1iZjRiYjg1ODM1MzcifWHOwa4-W2YE3a_6zUNhYPytUp7pbcab_KIEHqEmn3mhkWJ8ibuYhKOOSAjMbMbZRhinGFPmxHxIICcB7AeBES8-WlNQEGWoy-46sMrYv2nS9mJQ88h2E8qZOixsMH7FaYSD9q0cUE18LioPoyoJWHcHOys0ofZe1GcFE1eesYWDT7oBfv-4vat18l3DxEG8Ff6H_xXdm5Eva4pgBReSjSIu1qOm6ptG3LFRhHVbn9de2S6CyFpT623mmwIF8fjrBkDfjULj0gzm7nFhn20PAVYaAHJ4BaRTxXlZosHceOMt_TsNWLb7uf1MQIsmnB7qt1AFk2mhcHVQQBaDCZkeYY4.ZTA2OTdiZTItNzgyYy00YWI5LWFmODQtZjdkYmJkODNkMmFh';

// This is the URL that fetches the map images
const String _TILE_URL =
    'https://maps.geo.$_AWS_REGION.amazonaws.com/maps/v0/maps/$_MAP_NAME/tiles/{z}/{x}/{y}?key=$_API_KEY';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Starting Center (Simulating Naga City/Bicol since that's your region)
  LatLng _mapCenter = const LatLng(13.6218, 123.1948); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Map Test'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 14.0, 
            ),
            children: [
              TileLayer(
                urlTemplate: _TILE_URL,
                userAgentPackageName: 'com.example.gala',
                // Handle errors if tiles fail to load
                errorImage: const NetworkImage('https://via.placeholder.com/256x256.png?text=Error'),
              ),
              // Marker to show center
              MarkerLayer(
                markers: [
                  Marker(
                    point: _mapCenter,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white70,
              child: const Text(
                'Map Region: Sydney (ap-southeast-2)\nMap Name: MyAppMap',
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}