import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerScreen({super.key, required this.initialPosition});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng selectedPosition;
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  
  List<SearchResult> searchResults = [];
  bool isSearching = false;
  bool showResults = false;
  String currentAddress = "";
  bool isLoadingAddress = false;
  
  // Pin mode state
  bool isPinMode = false;
  LatLng? pinnedLocation;

  @override
  void initState() {
    super.initState();
    selectedPosition = widget.initialPosition.latitude == 0
        ? LatLng(13.6218, 123.1948) // Default: Naga City
        : widget.initialPosition;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Toggle pin mode
  void _togglePinMode() {
    setState(() {
      isPinMode = !isPinMode;
      if (!isPinMode) {
        // If turning off pin mode and no pin was placed, clear address
        if (pinnedLocation == null) {
          currentAddress = "";
        }
      } else {
        // Clear previous pin when entering pin mode
        pinnedLocation = null;
        currentAddress = "Tap on map to place pin";
      }
    });
  }

  // Handle map tap in pin mode
  void _onMapTap(LatLng point) {
    if (isPinMode) {
      setState(() {
        pinnedLocation = point;
        selectedPosition = point;
      });
      _updateAddress();
    }
  }

  // Search location using Nominatim API (OpenStreetMap)
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showResults = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
      showResults = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'GalaApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          searchResults = data
              .map((item) => SearchResult(
                    displayName: item['display_name'],
                    lat: double.parse(item['lat']),
                    lon: double.parse(item['lon']),
                  ))
              .toList();
          isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  // Update address with fallback to Nominatim API
  Future<void> _updateAddress() async {
    setState(() {
      isLoadingAddress = true;
      currentAddress = "Fetching address...";
    });

    try {
      // First try using geocoding package
      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedPosition.latitude,
        selectedPosition.longitude,
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw Exception('Geocoding timeout'),
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          currentAddress = _formatAddress(place);
          isLoadingAddress = false;
        });
        return;
      }
    } catch (e) {
      print('Geocoding package failed: $e');
      // Continue to fallback
    }

    // Fallback: Use Nominatim reverse geocoding API
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=${selectedPosition.latitude}&'
        'lon=${selectedPosition.longitude}&'
        'format=json&'
        'addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'GalaApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['address'] != null) {
          final address = data['address'];
          final addressParts = <String>[];
          
          // Build address from available components
          if (address['road'] != null) addressParts.add(address['road']);
          if (address['suburb'] != null) addressParts.add(address['suburb']);
          if (address['city'] != null) addressParts.add(address['city']);
          if (address['state'] != null) addressParts.add(address['state']);
          if (address['country'] != null) addressParts.add(address['country']);
          
          setState(() {
            currentAddress = addressParts.isNotEmpty 
                ? addressParts.join(', ') 
                : data['display_name'] ?? 'Address found';
            isLoadingAddress = false;
          });
          return;
        }
      }
    } catch (e) {
      print('Nominatim API failed: $e');
    }

    // If all methods fail
    setState(() {
      currentAddress = '${selectedPosition.latitude.toStringAsFixed(6)}, ${selectedPosition.longitude.toStringAsFixed(6)}';
      isLoadingAddress = false;
    });
  }

  String _formatAddress(Placemark place) {
    List<String> parts = [];
    if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
    if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
    if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown location';
  }

  void _onSearchResultTap(SearchResult result) {
    setState(() {
      selectedPosition = LatLng(result.lat, result.lon);
      pinnedLocation = selectedPosition;
      searchController.clear();
      showResults = false;
      searchResults = [];
      isPinMode = false;
    });
    
    mapController.move(selectedPosition, 16);
    _updateAddress();
  }

  Future<void> _confirmLocation() async {
    if (pinnedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pin a location first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      "lat": selectedPosition.latitude,
      "lng": selectedPosition.longitude,
      "address": currentAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF12397C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pin Location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedPosition,
              initialZoom: 16,
              onTap: (_, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.gala',
              ),
              // Marker layer - only show if pin is placed
              if (pinnedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pinnedLocation!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Pin Mode Instructions
          if (isPinMode && pinnedLocation == null)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app,
                      color: Color(0xFF12397C),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Tap anywhere on the map to place pin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600]),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  searchResults = [];
                                  showResults = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.length > 2) {
                        _searchLocation(value);
                      } else {
                        setState(() {
                          searchResults = [];
                          showResults = false;
                        });
                      }
                    },
                  ),
                ),

                // Search Results
                if (showResults && searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: searchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[200],
                      ),
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: const Color(0xFF12397C),
                            size: 22,
                          ),
                          title: Text(
                            result.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _onSearchResultTap(result),
                        );
                      },
                    ),
                  ),

                if (isSearching)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Pin Mode Button (Right side)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'pinButton',
                  onPressed: _togglePinMode,
                  backgroundColor: isPinMode ? Colors.red : const Color(0xFF12397C),
                  child: Icon(
                    isPinMode ? Icons.close : Icons.push_pin,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                if (isPinMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Pin Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Address Display Card - only show when pin is placed
          if (pinnedLocation != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12397C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF12397C),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          isLoadingAddress
                              ? Row(
                                  children: [
                                    SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Fetching address...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  currentAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
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
            ),

          // Confirm Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pinnedLocation != null
                    ? const Color(0xFF12397C)
                    : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (isLoadingAddress || pinnedLocation == null) 
                  ? null 
                  : _confirmLocation,
              child: isLoadingAddress
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      pinnedLocation == null 
                          ? "Click pin button to start" 
                          : "Confirm this location",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Search Result Model
class SearchResult {
  final String displayName;
  final double lat;
  final double lon;

  SearchResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });
}
