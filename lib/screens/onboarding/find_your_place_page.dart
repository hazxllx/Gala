import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FindYourPlacePage extends StatefulWidget {
  @override
  _FindYourPlacePageState createState() => _FindYourPlacePageState();
}

class _FindYourPlacePageState extends State<FindYourPlacePage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _locations = [
    'J. Hernandez Avenue, Naga City',
    'J. Hernandez Street, Iriga City',
    'J. Hernandez Extension, Pili',
    'J. Hernandez, Libmanan',
  ];

  final Map<String, LatLng> locationCoordinates = {
    'J. Hernandez Avenue, Naga City': LatLng(13.6218, 123.1947),
    'J. Hernandez Street, Iriga City': LatLng(13.4210, 123.4175),
    'J. Hernandez Extension, Pili': LatLng(13.5747, 123.2816),
    'J. Hernandez, Libmanan': LatLng(13.6912, 122.9874),
  };

  LatLng? _selectedLocation;
  String? _selectedLocationName;
  List<String> _filteredSuggestions = [];
  bool _showConfirmationDialog = false;

  void _onLocationSelected(String location) {
    setState(() {
      _selectedLocation = locationCoordinates[location];
      _selectedLocationName = location;
      _filteredSuggestions.clear();
      _searchController.clear();
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, 15.0);
      }
    });
  }

  void _filterSuggestions(String input) {
    setState(() {
      _filteredSuggestions =
          _locations
              .where(
                (location) =>
                    location.toLowerCase().contains(input.toLowerCase()),
              )
              .toList();
    });
  }

  void _confirmLocation() {
    setState(() {
      _showConfirmationDialog = true;
    });
  }

  void _finalizeLocation() {
    Navigator.pushNamed(
      context,
      '/success',
      arguments: {'location': _selectedLocationName!},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(13.6199, 123.1353),
              zoom: 10.0,
              maxBounds: LatLngBounds(LatLng(13.0, 122.5), LatLng(14.0, 123.8)),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterSuggestions,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    hintText: 'Search location...',
                    hintStyle: const TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                  ),
                ),
                if (_filteredSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          _filteredSuggestions.map((suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                              onTap: () => _onLocationSelected(suggestion),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedLocation != null && _selectedLocationName != null)
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLocationName!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lat: ${_selectedLocation!.latitude}, Lng: ${_selectedLocation!.longitude}',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Set background to blue
                          foregroundColor: Colors.white, // Text color
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4, // Adds shadow
                        ),
                        child: const Text(
                          'Go',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_showConfirmationDialog)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Is this your location?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _finalizeLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  3,
                                  102,
                                  182,
                                ),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: Colors.black,
                              ),
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showConfirmationDialog = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  230,
                                  228,
                                  228,
                                ),
                                foregroundColor: Colors.black,
                                elevation: 4,
                                shadowColor: Colors.black,
                              ),
                              child: const Text(
                                'No, Change',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
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
            ),
        ],
      ),
    );
  }
}
