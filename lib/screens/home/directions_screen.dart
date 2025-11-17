import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

/// Represents a route option with its path, distance, and duration
class RouteOption {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds
  final String description; // e.g., "Fastest", "Shortest", "Alternative"

  RouteOption({
    required this.points,
    required this.distance,
    required this.duration,
    required this.description,
  });
}

class DirectionsScreen extends StatefulWidget {
  const DirectionsScreen({super.key});

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _startSearchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final LayerLink _startLayerLink = LayerLink();
  String _startName = ''; // Holds the display name for the start coordinates
  bool _isStartFieldFocused = false;
  Location? _startLocation; // Holds the Location object for the start
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _startController =
      TextEditingController(); // Controller for manual start input

  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];
  List<Marker> _markers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _destinationName;
  bool _isSearching = false;

  // Route information
  double? _routeDistance; // in meters
  double? _routeDuration; // in seconds

  // Multiple route options
  List<RouteOption> _routeOptions = [];
  int _selectedRouteIndex = 0;

  // Search suggestions
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    // Initialize map controller
    _mapController = MapController();

    // 1. Initialize the new controllers
    _destinationController = TextEditingController();
    _startController = TextEditingController();

    // 2. Set default start text
    _startController.text = _startName;

    // 3. Keep the original searchController (used by existing logic)
    // synchronized with the new destination controller
    _destinationController.addListener(_handleDestinationTextChange);
    _startController.addListener(_handleStartTextChange);

    // 4. Get location and set default start coordinates
    _getCurrentLocation();

    // 5. Focus listeners for both search fields
    _searchFocusNode.addListener(() {
      setState(() => _isStartFieldFocused = false);
      if (!_searchFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_searchFocusNode.hasFocus && !_isStartFieldFocused) {
            _removeOverlay();
          }
        });
      }
    });

    _startSearchFocusNode.addListener(() {
      setState(() => _isStartFieldFocused = _startSearchFocusNode.hasFocus);
      if (_startSearchFocusNode.hasFocus) {
        _handleStartTextChange();
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!_startSearchFocusNode.hasFocus && !_searchFocusNode.hasFocus) {
            _removeOverlay();
          }
        });
      }
    });
  }

  void _swapLocations() {
  setState(() {
    // Swap names/controllers
    String? tempName = _startName;
    _startName = _destinationName ?? _startController.text;
    _destinationName = tempName;

    // Convert start location to LatLng if needed
    LatLng? startLatLng = _startLocation != null 
        ? LatLng(_startLocation!.latitude, _startLocation!.longitude)
        : null;
        
    // Store the destination temporarily
    LatLng? tempDestination = _destinationLocation;
    
    // Update destination with start location
    _destinationLocation = startLatLng;
    
    // Update start location from the temp destination
    if (tempDestination != null) {
      _startLocation = Location(
        latitude: tempDestination.latitude,
        longitude: tempDestination.longitude,
        timestamp: DateTime.now()
      );
    } else {
      _startLocation = null;
    }

    // Swap text in controllers
    String tempText = _startController.text;
    _startController.text = _destinationController.text;
    _destinationController.text = tempText;
    _searchController.text = _destinationController.text; // Keep search/destination synchronized
    
    // Re-calculate the route with the new start/destination
    if (_startLocation != null && _destinationLocation != null) {
      // Convert start location to LatLng for route calculation
      LatLng startLatLng = LatLng(_startLocation!.latitude, _startLocation!.longitude);
      _calculateRoute(startLatLng, _destinationLocation!);
    } else {
      _clearRoute();
    }
  });
}

  // Handle text changes for both inputs
  void _handleDestinationTextChange() {
    if (!_isStartFieldFocused && _searchController.text != _destinationController.text) {
      _searchController.text = _destinationController.text;
      _getSearchSuggestions(_destinationController.text);
    }
  }

  void _handleStartTextChange() {
    if (_isStartFieldFocused && _searchController.text != _startController.text) {
      _searchController.text = _startController.text;
      _getSearchSuggestions(_startController.text);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage =
              'Location services are disabled. Please enable them in settings.';
          _isLoading = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage =
                'Location permission denied. Please enable location access in settings.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permission permanently denied. Please enable it in app settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        // Update start name with coordinates
        _startName = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _startController.text = _startName;
      });

      // Add current location marker
      _addCurrentLocationMarker();

      // Move map to current location
      _mapController.move(_currentLocation!, 14.0);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get current location: $e';
        _isLoading = false;
      });
    }
  }

  void _addCurrentLocationMarker() {
    if (_currentLocation == null) return;

    setState(() {
      _markers = [
        Marker(
          point: _currentLocation!,
          width: 50,
          height: 50,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
        ),
      ];
    });
  }

  Future<void> _searchDestination(
    String query, {
    LatLng? location,
    String? name,
  }) async {
    if (query.isEmpty && location == null) return;
    if (_currentLocation == null) return;

    // Hide suggestions
    _removeOverlay();
    setState(() {
      _showSuggestions = false;
      _isSearching = true;
      _errorMessage = null;
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
    });

    try {
      LatLng destination;
      String destinationName;

      if (location != null && name != null) {
        // Use provided location and name from suggestion
        // Verify location is within Camarines Sur
        if (location.latitude < 13.0 ||
            location.latitude > 14.5 ||
            location.longitude < 122.5 ||
            location.longitude > 124.0) {
          setState(() {
            _errorMessage = 'Selected location is outside Camarines Sur area';
            _isSearching = false;
          });
          return;
        }
        destination = location;
        destinationName = name;
      } else {
        // Use Nominatim search restricted to Camarines Sur instead of generic geocoding
        // This ensures we only get results within the province
        try {
          final boundingBox = _getCamarinesSurBoundingBox();
          final url = Uri.parse(
            'https://nominatim.openstreetmap.org/search?'
            'q=${Uri.encodeComponent(query)}&'
            'format=json&'
            'limit=1&'
            'addressdetails=1&'
            'bounded=1&'
            'viewbox=$boundingBox&'
            'countrycodes=ph',
          );

          final response = await http.get(
            url,
            headers: {'User-Agent': 'GalaApp/1.0'},
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);

            if (data.isEmpty) {
              setState(() {
                _errorMessage =
                    'No results found for "$query" in Camarines Sur';
                _isSearching = false;
              });
              return;
            }

            // Get the first result and verify it's in Camarines Sur
            final item = data.first;
            final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
            final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;

            // Verify location is within Camarines Sur
            if (lat < 13.0 || lat > 14.5 || lon < 122.5 || lon > 124.0) {
              setState(() {
                _errorMessage = 'Location found outside Camarines Sur area';
                _isSearching = false;
              });
              return;
            }

            destination = LatLng(lat, lon);
            destinationName = item['display_name'] ?? item['name'] ?? query;

            // Try to get a better name from reverse geocoding
            try {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                lat,
                lon,
              );
              if (placemarks.isNotEmpty) {
                Placemark place = placemarks.first;
                destinationName =
                    place.name ??
                    place.street ??
                    place.locality ??
                    place.administrativeArea ??
                    destinationName;
              }
            } catch (e) {
              // Use display name as fallback
            }
          } else {
            setState(() {
              _errorMessage = 'Search failed. Please try again.';
              _isSearching = false;
            });
            return;
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to search for destination: $e';
            _isSearching = false;
          });
          return;
        }
      }

      _destinationLocation = destination;
      _destinationName = destinationName;

      // Add destination marker
      setState(() {
        _markers = [
          Marker(
            point: _currentLocation!,
            width: 50,
            height: 50,
            child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
          ),
          Marker(
            point: _destinationLocation!,
            width: 50,
            height: 50,
            child: const Icon(Icons.location_on, color: Colors.red, size: 50),
          ),
        ];
      });

      // Calculate route
      await _calculateRoute(_currentLocation!, destination);

      // Move map to show both locations
      double minLat =
          _currentLocation!.latitude < _destinationLocation!.latitude
              ? _currentLocation!.latitude
              : _destinationLocation!.latitude;
      double maxLat =
          _currentLocation!.latitude > _destinationLocation!.latitude
              ? _currentLocation!.latitude
              : _destinationLocation!.latitude;
      double minLng =
          _currentLocation!.longitude < _destinationLocation!.longitude
              ? _currentLocation!.longitude
              : _destinationLocation!.longitude;
      double maxLng =
          _currentLocation!.longitude > _destinationLocation!.longitude
              ? _currentLocation!.longitude
              : _destinationLocation!.longitude;

      LatLng center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

      // Calculate zoom level to fit both points
      double latDiff = maxLat - minLat;
      double lngDiff = maxLng - minLng;
      double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
      double zoom = maxDiff > 0.1 ? 10.0 : (maxDiff > 0.05 ? 12.0 : 14.0);

      _mapController.move(center, zoom);

      setState(() {
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search for destination: $e';
        _isSearching = false;
      });
    }
  }

  Future<void> _calculateRoute(LatLng start, LatLng end) async {
    try {
      setState(() {
        _routeOptions = [];
        _selectedRouteIndex = 0;
      });

      // Use OSRM (Open Source Routing Machine) API - free and no API key required
      // Format: start longitude,start latitude;end longitude,end latitude
      // Add alternatives=true to get multiple route options
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson&steps=true&alternatives=true',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final routes = data['routes'] as List;

          // Process all route options
          List<RouteOption> routeOptions = [];

          for (int i = 0; i < routes.length; i++) {
            final route = routes[i];
            final geometry = route['geometry'];
            final coordinates = geometry['coordinates'] as List;

            // Extract distance (in meters) and duration (in seconds)
            final distance = route['distance']?.toDouble() ?? 0;
            final baseDuration = route['duration']?.toDouble() ?? 0;

            // Calculate more realistic duration
            double adjustedDuration = _calculateRealisticDuration(
              distance,
              baseDuration,
            );

            // Convert coordinates to LatLng points
            final points =
                coordinates.map<LatLng>((coord) {
                  // GeoJSON format is [longitude, latitude]
                  return LatLng(coord[1].toDouble(), coord[0].toDouble());
                }).toList();

            // Determine route description
            String description;
            if (i == 0) {
              description = 'Fastest route';
            } else if (i == 1) {
              description = 'Alternative route';
            } else {
              description = 'Route ${i + 1}';
            }

            routeOptions.add(
              RouteOption(
                points: points,
                distance: distance,
                duration: adjustedDuration,
                description: description,
              ),
            );
          }

          // Sort routes by duration (fastest first)
          routeOptions.sort((a, b) => a.duration.compareTo(b.duration));

          setState(() {
            _routeOptions = routeOptions;
            _selectedRouteIndex = 0;
            if (routeOptions.isNotEmpty) {
              _routePoints = routeOptions[0].points;
              _routeDistance = routeOptions[0].distance;
              _routeDuration = routeOptions[0].duration;
            }
          });
        } else {
          setState(() {
            _errorMessage = 'Could not calculate route. Please try again.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Route calculation failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating route: $e';
      });
    }
  }

  void _selectRoute(int index) {
    if (index >= 0 && index < _routeOptions.length) {
      setState(() {
        _selectedRouteIndex = index;
        _routePoints = _routeOptions[index].points;
        _routeDistance = _routeOptions[index].distance;
        _routeDuration = _routeOptions[index].duration;
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

  /// Calculate more realistic travel time based on distance and local conditions
  /// Accounts for traffic, stops, and typical urban driving speeds in the Philippines
  double _calculateRealisticDuration(
    double distanceMeters,
    double osrmDurationSeconds,
  ) {
    if (distanceMeters <= 0) return osrmDurationSeconds;

    final distanceKm = distanceMeters / 1000;

    // Calculate realistic average speeds based on distance
    // Shorter distances in cities typically have lower average speeds due to:
    // - Traffic lights
    // - Traffic congestion
    // - Multiple turns
    // - Urban speed limits

    double averageSpeedKmh;

    if (distanceKm < 1) {
      // Very short distances (under 1km): 15-20 km/h average (heavy traffic, many stops)
      averageSpeedKmh = 18;
    } else if (distanceKm < 3) {
      // Short distances (1-3km): 20-25 km/h average (city traffic)
      averageSpeedKmh = 22;
    } else if (distanceKm < 10) {
      // Medium distances (3-10km): 25-35 km/h average (mixed urban/suburban)
      averageSpeedKmh = 30;
    } else {
      // Longer distances: 35-45 km/h average (more highway/major roads)
      averageSpeedKmh = 40;
    }

    // Calculate time based on realistic speed (time = distance / speed)
    // Convert km/h to m/s: 1 km/h = 1000m / 3600s = 0.2778 m/s
    final realisticDurationSeconds =
        distanceMeters / (averageSpeedKmh * 0.2778);

    // Use the longer of OSRM duration or realistic calculation
    // This ensures we don't underestimate, and accounts for:
    // - Actual route complexity (OSRM)
    // - Real-world traffic conditions (realistic calculation)
    final finalDuration =
        realisticDurationSeconds > osrmDurationSeconds
            ? realisticDurationSeconds
            : osrmDurationSeconds *
                1.3; // Add 30% buffer to OSRM if it's shorter

    return finalDuration;
  }

  void _getSearchSuggestions(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty || query.length < 2) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    // Debounce: Wait 400ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  /// Get bounding box for Camarines Sur, Philippines
  /// Format: min_lon, max_lat, max_lon, min_lat (viewbox format)
  String _getCamarinesSurBoundingBox() {
    // Camarines Sur approximate boundaries
    // min_lon, max_lat, max_lon, min_lat
    return '122.5,14.5,124.0,13.0';
  }

  /// Get viewbox centered on current location for nearby searches
  String _getNearbyViewbox() {
    if (_currentLocation == null) {
      return _getCamarinesSurBoundingBox();
    }
    // Create a viewbox around current location (about 20km radius)
    final radius = 0.15; // approximately 15km
    return '${_currentLocation!.longitude - radius},${_currentLocation!.latitude + radius},${_currentLocation!.longitude + radius},${_currentLocation!.latitude - radius}';
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    try {
      String url;
      final viewbox = _getNearbyViewbox();
      final boundingBox = _getCamarinesSurBoundingBox();

      // Check if user is searching for a place type (cafe, restaurant, etc.)
      // If current location is available, search for nearby places within Camarines Sur
      if (_currentLocation != null && _isPlaceTypeQuery(query)) {
        // Search for nearby places using Nominatim with proximity search
        // Restrict to Camarines Sur area
        url =
            Uri.parse(
              'https://nominatim.openstreetmap.org/search?'
              'q=${Uri.encodeComponent(query)}&'
              'format=json&'
              'limit=10&'
              'addressdetails=1&'
              'bounded=1&'
              'viewbox=$viewbox&'
              'dedupe=1',
            ).toString();
      } else {
        // Regular address/place search restricted to Camarines Sur
        url =
            Uri.parse(
              'https://nominatim.openstreetmap.org/search?'
              'q=${Uri.encodeComponent(query)}&'
              'format=json&'
              'limit=10&'
              'addressdetails=1&'
              'bounded=1&'
              'viewbox=$boundingBox&'
              'countrycodes=ph',
            ).toString();
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'GalaApp/1.0', // Required by Nominatim
        },
      );

      if (response.statusCode == 200 && mounted) {
        final List<dynamic> data = json.decode(response.body);

        // Verify this is still the current query
        if (_searchController.text == query) {
          List<Map<String, dynamic>> suggestions = [];

          // If we have current location, sort by distance
          if (_currentLocation != null) {
            suggestions =
                data.map<Map<String, dynamic>>((item) {
                  final lat =
                      double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
                  final lon =
                      double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;
                  final distance = _calculateDistance(
                    _currentLocation!,
                    LatLng(lat, lon),
                  );

                  return {
                    'name': item['display_name'] ?? item['name'] ?? 'Unknown',
                    'lat': lat,
                    'lon': lon,
                    'distance': distance,
                    'type': item['type'] ?? item['class'] ?? '',
                  };
                }).toList();

            // Sort by distance if current location is available
            suggestions.sort((a, b) {
              final distA = a['distance'] as double;
              final distB = b['distance'] as double;
              return distA.compareTo(distB);
            });

            // Take top 8 results
            suggestions = suggestions.take(8).toList();
          } else {
            suggestions =
                data.map<Map<String, dynamic>>((item) {
                  return {
                    'name': item['display_name'] ?? item['name'] ?? 'Unknown',
                    'lat':
                        double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
                    'lon':
                        double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
                    'distance': 0.0,
                    'type': item['type'] ?? item['class'] ?? '',
                  };
                }).toList();
          }

          // Filter results to ensure they're in Camarines Sur
          // Check if results are within the bounding box
          final filteredSuggestions =
              suggestions.where((suggestion) {
                final lat = suggestion['lat'] as double;
                final lon = suggestion['lon'] as double;
                // Camarines Sur boundaries: lat 13.0-14.5, lon 122.5-124.0
                return lat >= 13.0 &&
                    lat <= 14.5 &&
                    lon >= 122.5 &&
                    lon <= 124.0;
              }).toList();

          setState(() {
            _searchSuggestions = filteredSuggestions;
            _showSuggestions = _searchSuggestions.isNotEmpty;
          });

          if (_showSuggestions && _searchFocusNode.hasFocus) {
            _showSuggestionsOverlay();
          }
        }
      }
    } catch (e) {
      // Silently fail for suggestions
      print('Error getting suggestions: $e');
    }
  }

  /// Check if the query is a place type (cafe, restaurant, etc.)
  bool _isPlaceTypeQuery(String query) {
    final queryLower = query.toLowerCase().trim();
    final placeTypes = [
      'cafe',
      'coffee',
      'restaurant',
      'bar',
      'shop',
      'store',
      'mall',
      'hotel',
      'hospital',
      'pharmacy',
      'bank',
      'atm',
      'gas',
      'fuel',
      'parking',
      'school',
      'university',
      'church',
      'temple',
      'mosque',
      'gym',
      'park',
      'beach',
      'market',
      'supermarket',
      'pharmacy',
      'clinic',
      'dentist',
      'salon',
      'spa',
      'cinema',
      'theater',
      'museum',
      'library',
      'post office',
      'police',
      'fire station',
    ];

    return placeTypes.any((type) => queryLower.contains(type));
  }

  /// Calculate distance between two points in meters using Haversine formula
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(point2.latitude - point1.latitude);
    final double dLon = _toRadians(point2.longitude - point1.longitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  Widget _buildQuickFilterChip(
    String label,
    IconData icon,
    Color textColor,
    Color cardColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _searchController.text = label.toLowerCase();
            _getSearchSuggestions(label.toLowerCase());
            _searchFocusNode.requestFocus();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: const Color(0xFF1976D2)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuggestionsOverlay() {
    _removeOverlay();

    if (!_showSuggestions || _searchSuggestions.isEmpty) return;
    if (!mounted) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Close suggestions when tapping outside
              _removeOverlay();
            },
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 120), // Increased offset to avoid overlap with search bar
              child: GestureDetector(
                onTap: () {}, // Prevent tap from bubbling up
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = _searchSuggestions[index];
                        final distance = suggestion['distance'] as double;
                        final hasDistance =
                            distance > 0 && _currentLocation != null;

                        // Determine icon based on place type
                        IconData placeIcon = Icons.location_on;
                        final type =
                            (suggestion['type'] as String).toLowerCase();
                        if (type.contains('cafe') || type.contains('coffee')) {
                          placeIcon = Icons.local_cafe;
                        } else if (type.contains('restaurant') ||
                            type.contains('food')) {
                          placeIcon = Icons.restaurant;
                        } else if (type.contains('shop') ||
                            type.contains('store')) {
                          placeIcon = Icons.shopping_bag;
                        } else if (type.contains('hotel')) {
                          placeIcon = Icons.hotel;
                        } else if (type.contains('gas') ||
                            type.contains('fuel')) {
                          placeIcon = Icons.local_gas_station;
                        } else if (type.contains('parking')) {
                          placeIcon = Icons.local_parking;
                        } else if (type.contains('hospital') ||
                            type.contains('clinic')) {
                          placeIcon = Icons.local_hospital;
                        } else if (type.contains('pharmacy')) {
                          placeIcon = Icons.local_pharmacy;
                        } else if (type.contains('bank') ||
                            type.contains('atm')) {
                          placeIcon = Icons.account_balance;
                        } else if (type.contains('school') ||
                            type.contains('university')) {
                          placeIcon = Icons.school;
                        } else if (type.contains('park')) {
                          placeIcon = Icons.park;
                        }

                        return InkWell(
                          onTap: () {
                            _removeOverlay();
                            _searchFocusNode.unfocus();
                            _searchController.text =
                                suggestion['name'] as String;
                            _searchDestination(
                              suggestion['name'] as String,
                              location: LatLng(
                                suggestion['lat'] as double,
                                suggestion['lon'] as double,
                              ),
                              name: suggestion['name'] as String,
                            );
                          },
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              placeIcon,
                              color: Colors.red,
                              size: 20,
                            ),
                            title: Text(
                              suggestion['name'] as String,
                              style: TextStyle(color: textColor, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing:
                                hasDistance
                                    ? Text(
                                      _formatDistance(distance),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    )
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _clearRoute() {
    _removeOverlay();
    setState(() {
      _destinationLocation = null;
      _routePoints = [];
      _destinationName = null;
      _routeDistance = null;
      _routeDuration = null;
      _routeOptions = [];
      _selectedRouteIndex = 0;
      _searchController.clear();
      _searchSuggestions = [];
      _showSuggestions = false;
    });
    _addCurrentLocationMarker();
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 14.0);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final bgColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
    final cardColor =
        isDarkMode
            ? (Colors.grey[900] ?? const Color(0xFF121212))
            : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Get Directions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          if (_currentLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(_currentLocation!, 14.0);
              },
              tooltip: 'Center on current location',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          if (_currentLocation != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 14.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: (tapPosition, latLng) {
                  // Close suggestions when map is tapped
                  _removeOverlay();
                  _searchFocusNode.unfocus();
                },
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.my_project',
                  maxZoom: 19,
                ),
                // Route polylines - show all routes, highlight selected
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      // Selected route (thicker, brighter)
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 6.0,
                        color: Colors.blue,
                      ),
                      // Other routes (thinner, lighter)
                      ..._routeOptions
                          .asMap()
                          .entries
                          .where((entry) {
                            return entry.key != _selectedRouteIndex;
                          })
                          .map((entry) {
                            return Polyline(
                              points: entry.value.points,
                              strokeWidth: 3.0,
                              color: Colors.grey.withOpacity(0.5),
                            );
                          }),
                    ],
                  ),
                // Markers
                MarkerLayer(markers: _markers),
              ],
            )
          else
            Center(
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage ?? 'Getting your location...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('Retry'),
                            ),
                          ],
                        ],
                      ),
            ),

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Start/Destination Icons
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.trip_origin,
                            color: Colors.green,
                            size: 16,
                          ),
                          Container(height: 30, width: 1, color: Colors.grey),
                          Icon(Icons.location_on, color: Colors.red, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Input Fields
                    Expanded(
                      child: Column(
                        children: [
                          // Start Address Input (Default: Current Location)
                          TextField(
                            controller: _startController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Start location (Current Location)',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            onTap: () {
                              // This could open a full screen for searching the start point
                              // For now, it allows manual text input
                              _removeOverlay();
                            },
                            
                            onSubmitted: (value) {
                              // You'll need a new function like _searchStart(value)
                              // For simplicity, we just update the display name here
                              setState(() {
                                _startName = value;
                              });
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[300]),

                          // Destination Address Input
                          TextField(
                            controller:
                                _destinationController, // Use a separate controller
                            focusNode: _searchFocusNode,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Choose destination...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            // Use existing search logic for the destination field
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _searchDestination(value);
                              }
                            },
                            onChanged: (value) {
                              // Synchronize with the original search controller for suggestions
                              _searchController.text = value;
                              setState(() {});
                              if (value.length >= 2) {
                                _getSearchSuggestions(value);
                              } else {
                                _removeOverlay();
                                setState(() {
                                  _showSuggestions = false;
                                  _searchSuggestions = [];
                                });
                              }
                            },
                            onTap: () {
                              if (_destinationController.text.isNotEmpty &&
                                  _searchSuggestions.isNotEmpty) {
                                _showSuggestionsOverlay();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Switch Button
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 12.0),
                      child: IconButton(
                        icon: Icon(Icons.swap_vert, color: Colors.blue[700]),
                        onPressed: _swapLocations,
                        tooltip: 'Swap Start and Destination',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick filter chips for common place types
          if (_currentLocation != null && _searchController.text.isEmpty)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: Container(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickFilterChip(
                      'Cafe',
                      Icons.local_cafe,
                      textColor,
                      cardColor,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickFilterChip(
                      'Restaurant',
                      Icons.restaurant,
                      textColor,
                      cardColor,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickFilterChip(
                      'Gas Station',
                      Icons.local_gas_station,
                      textColor,
                      cardColor,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickFilterChip(
                      'Hospital',
                      Icons.local_hospital,
                      textColor,
                      cardColor,
                      isDarkMode,
                    ),
                    const SizedBox(width: 8),
                    _buildQuickFilterChip(
                      'ATM',
                      Icons.account_balance,
                      textColor,
                      cardColor,
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ),

          // Destination info and clear button
          if (_destinationLocation != null && _destinationName != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _destinationName!,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_routeDistance != null &&
                                  _routeDuration != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.route,
                                            size: 16,
                                            color: Colors.blue[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDistance(_routeDistance!),
                                            style: TextStyle(
                                              color: Colors.blue[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.orange[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDuration(_routeDuration!),
                                            style: TextStyle(
                                              color: Colors.orange[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Estimated time (may vary with traffic)',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Route options button
                              if (_routeOptions.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: InkWell(
                                    onTap: _showRouteOptions,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.alt_route,
                                            size: 16,
                                            color: Colors.blue[700],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_routeOptions.length} route options',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.blue[700],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          color: Colors.grey[500],
                          onPressed: _clearRoute,
                          tooltip: 'Clear route',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator
          if (_isSearching)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Searching...',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null && !_isLoading)
            Positioned(
              bottom: _destinationLocation != null ? 100 : 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900], fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: Colors.red[700],
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
