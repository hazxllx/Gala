import 'package:flutter/material.dart';
import 'package:my_project/services/firebase_storage_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // Required for bbox calculations
import 'dart:io'; // For File
import 'dart:ui'; // For ImageFilter
// Firebase Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Auth
import 'package:image_picker/image_picker.dart';

// --- CONFIG ---
const String _AWS_REGION = 'ap-southeast-1';
const String _PLACE_INDEX = 'MyPlaceIndex';
const String _API_KEY =
    'v1.public.eyJqdGkiOiJmNjYzMGVlYi0xNzA2LTQxNDItYWQyYy1jYzMzNTc0NGM0ZmIifQg38P6cE6L4sb71GcGuteb40sqtqQlariMJDviQkWwltWUwfUEc8rSPmUo3vtOHGEL0U0z9vpQBeVbdNfZZ886jGXhNY9Kc6xdNykSCuqleZ2gVOgb6YxLay0F9wTr2d9Uzv5wawpQEfhucGX8y9trnEAm68wSvCorCGAFlPMOsW2MAzEEMMsKpFMZ6Cf3rTO_v-_YHLniGzuWRiID0tY_d2pJBo9egY6QeYFNI-srp2gMRlXoqzHxbBoCNVDSxwSMH7oEgAIvEso8-Cb3iQ-puWGftX8-kQ3uoEUkHXPiTlGksY72Hi9fkUkC20KeOvCX-RZ9RL2PIb_xjSEn89Ec.MzRjYzZmZGUtZmY3NC00NDZiLWJiMTktNTc4YjUxYTFlOGZi';

// --- HELPER CLASSES ---
class LatLng {
  final double latitude;
  final double longitude;
  LatLng(this.latitude, this.longitude);
}

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> with TickerProviderStateMixin {
  late final WebViewController _webViewController;
  
  // Animation Controllers
  late final AnimationController _slideInController;
  late final AnimationController _pulseController;

  // State
  Position? _currentPosition;
  bool _isLoading = false;
  
  // Default Location: Naga City, Camarines Sur
  final LatLng _defaultCamSurLocation = LatLng(13.6139, 123.1853);

  // Filters
  final List<String> _categories = [
    "Cafes", 
    "Resorts", 
    "Parks", 
    "Restaurant", 
    "Bars"
  ];
  
  // Mapping for broad search terms to get enough results
  final Map<String, String> _categorySearchTerms = {
    "Cafes": "Coffee",
    "Resorts": "Resort",
    "Parks": "Park",
    "Restaurant": "Restaurant", 
    "Bars": "Bar",
  };

  // Client-side keywords to strictly filter the results
  // We check if the returned 'Categories' list contains partial matches to these
  final Map<String, List<String>> _clientSideCategoryKeywords = {
    "Cafes": ["coffee", "cafe", "tea", "bakery"],
    "Resorts": ["resort", "hotel", "inn", "guest house"],
    "Parks": ["park", "garden", "recreation", "plaza", "playground"],
    "Restaurant": ["restaurant", "dining", "bistro", "grill", "eatery", "diner", "steakhouse", "pizza"], 
    "Bars": ["bar", "pub", "nightlife", "club", "lounge", "tavern"],
  };

  String _selectedCategory = "Cafes";
  double _radiusKm = 2.0; // Range: 1km to 10km

  // Selected Place Data
  Map<String, dynamic>? _selectedPlace;
  bool _isCardVisible = false;

  // --- REVIEW STATE ---
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<File> _reviewImages = [];
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize Animations
    _slideInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _initWebView();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _slideInController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'PlaceSelected',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final placeData = jsonDecode(message.message);
            _onPlaceTapped(placeData);
          } catch (e) {
            debugPrint("Error parsing place data: $e");
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // FIX: Immediately set map to Camarines Sur default
            _webViewController.runJavaScript(
              'if(map) map.jumpTo({center: [${_defaultCamSurLocation.longitude}, ${_defaultCamSurLocation.latitude}], zoom: 14});'
            );
            
            _getCurrentLocation();
            _slideInController.forward(); // Start animation when map loads
          },
          onWebResourceError: (error) {
            debugPrint("Map Resource Error: ${error.description}");
          },
        ),
      )
      ..loadFlutterAsset('assets/aws_map.html');
  }

  // --- 1. Location & API Logic ---

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showError("Location services disabled");
      // Fallback to default search even if GPS off
      _searchNearbyPlaces(useDefault: true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showError("Location permission denied");
        // Fallback
        _searchNearbyPlaces(useDefault: true);
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      
      if (!mounted) return;
      
      setState(() => _currentPosition = position);

      _webViewController.runJavaScript(
        'updateStartLocation(${position.latitude}, ${position.longitude})',
      );

      _searchNearbyPlaces();
    } catch (e) {
      debugPrint("Error getting location: $e");
      _searchNearbyPlaces(useDefault: true);
    }
  }

  Future<void> _searchNearbyPlaces({bool useDefault = false}) async {
    // Determine center point: User Position or Default CamSur
    double lat, lon;
    if (_currentPosition != null && !useDefault) {
      lat = _currentPosition!.latitude;
      lon = _currentPosition!.longitude;
    } else {
      lat = _defaultCamSurLocation.latitude;
      lon = _defaultCamSurLocation.longitude;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/text?key=$_API_KEY',
    );

    try {
      double latOffset = _radiusKm / 111.0;
      double lonOffset = _radiusKm / (111.0 * cos(lat * (pi / 180.0)));

      List<double> bbox = [
        lon - lonOffset,
        lat - latOffset,
        lon + lonOffset,
        lat + latOffset,
      ];

      final searchTerm = _categorySearchTerms[_selectedCategory] ?? _selectedCategory;
      final requiredKeywords = _clientSideCategoryKeywords[_selectedCategory] ?? [];

      final body = jsonEncode({
        "Text": searchTerm,
        "FilterBBox": bbox,
        // Removed FilterCategories to prevent API errors with HERE DataSource
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

        for (var item in results) {
          final place = item['Place'];
          final geom = place['Geometry']['Point'];
          final pLat = geom[1];
          final pLon = geom[0];
          
          final distMeters = Geolocator.distanceBetween(lat, lon, pLat, pLon);

          // CLIENT-SIDE FILTERING
          // Check if place categories match our strict keywords
          // This removes "Store" when searching for "Restaurant" if it lacks food-related tags
          bool isCategoryMatch = false;
          final placeCategories = (place['Categories'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
          
          // Also check label for keywords if categories are missing/sparse
          final labelLower = (place['Label'] as String? ?? "").toLowerCase();

          for (final keyword in requiredKeywords) {
            if (placeCategories.any((cat) => cat.contains(keyword)) || labelLower.contains(keyword)) {
              isCategoryMatch = true;
              break;
            }
          }

          if (distMeters <= (_radiusKm * 1000) && isCategoryMatch) {
            validPlaces.add({
              'id': place['PlaceId'] ?? place['Label'],
              'label': place['Label'] ?? "Unknown Place",
              'lat': pLat,
              'lon': pLon,
              'dist': distMeters,
              'categories': place['Categories'] ?? [],
            });
          }
        }

        final jsonString = jsonEncode(validPlaces);
        final safePayload = jsonEncode(jsonString);
        _webViewController.runJavaScript('updatePlaces($safePayload)');
      } else {
        debugPrint("AWS Error: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
      if (mounted) _showError("Network error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- REVIEW LOGIC ---

  String _getAnonymizedName() {
    final user = FirebaseAuth.instance.currentUser;
    final fullName = user?.displayName ?? "Anonymous";
    
    if (fullName == "Anonymous") return fullName;

    List<String> parts = fullName.split(' ');
    return parts.map((part) {
      if (part.isEmpty) return "";
      if (part.length == 1) return part;
      return part[0] + '*' * (part.length - 1);
    }).join(' ');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _reviewImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      _showError("Please select a rating.");
      return;
    }
    if (_selectedPlace == null) return;

    setState(() => _isSubmittingReview = true);

    try {
      List<String> imageUrls = [];
      if (_reviewImages.isNotEmpty) {
        imageUrls = await FirebaseStorageService.uploadEstablishmentImages(_reviewImages);
      }

      final user = FirebaseAuth.instance.currentUser;
      final anonymizedName = _getAnonymizedName();

      await FirebaseFirestore.instance.collection('reviews').add({
        'place_label': _selectedPlace!['label'],
        'place_id': _selectedPlace!['id'],
        'rating': _rating,
        'comment': _reviewController.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': user?.uid,
        'user_name': anonymizedName,
      });

      setState(() {
        _rating = 0;
        _reviewController.clear();
        _reviewImages.clear();
        _isSubmittingReview = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review submitted successfully!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF041D66),
          ),
        );
      }

    } catch (e) {
      print("Review Submit Error: $e");
      if (mounted) {
        setState(() => _isSubmittingReview = false);
        _showError("Failed to submit review: $e");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onPlaceTapped(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
      _isCardVisible = true;
      _rating = 0;
      _reviewController.clear();
      _reviewImages.clear();
    });
  }

  void _closeCard() {
    setState(() {
      _isCardVisible = false;
      _selectedPlace = null;
    });
  }

  // --- UI HELPER: Glass Card ---
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Map Layer
          WebViewWidget(controller: _webViewController),

          // 2. Filter Bar (Glassmorphism Slide-In)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                  .animate(CurvedAnimation(parent: _slideInController, curve: Curves.elasticOut)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- BACK BUTTON ---
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
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

                  // --- FILTERS CARD ---
                  _buildGlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Categories
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
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
                                    selectedColor: const Color(0xFF041D66),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    elevation: isSelected ? 4 : 0,
                                    shadowColor: Colors.black26,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

                        // Radius Slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.radar_rounded, size: 20, color: Colors.grey[700]),
                              const SizedBox(width: 12),
                              Text(
                                "${_radiusKm.toStringAsFixed(1)} km",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF041D66),
                                    inactiveTrackColor: Colors.grey[300],
                                    thumbColor: const Color(0xFF041D66),
                                    overlayColor: const Color(0xFF041D66).withOpacity(0.2),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    value: _radiusKm,
                                    min: 1.0,
                                    max: 10.0,
                                    divisions: 9,
                                    onChanged: (val) => setState(() => _radiusKm = val),
                                    onChangeEnd: (val) => _searchNearbyPlaces(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. GPS FAB (Pulsing)
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF041D66), Color(0xFF0A2E85)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF041D66).withOpacity(0.4 + (_pulseController.value * 0.2)),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Loading Overlay (Blurred)
          if (_isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: _buildGlassCard(
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF041D66)),
                            SizedBox(height: 16),
                            Text("Finding nearby places...", style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // 5. Slide-up Info Card
          if (_isCardVisible && _selectedPlace != null)
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,     
              maxChildSize: 0.95,    
              builder: (context, scrollController) {
                final label = _selectedPlace!['label'] as String;
                final name = label.split(',')[0];
                final address = label.replaceAll('$name, ', '');
                final distance = (_selectedPlace!['dist'] as double).toStringAsFixed(0);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 40, spreadRadius: 2)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 4),
                                    Text("$distance m away", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _closeCard,
                              color: Colors.grey[800],
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Text(address, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.4)),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // --- RATE & REVIEW SECTION ---
                      const Text(
                        "Rate & Review",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Star Rating
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _rating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: Colors.amber[700],
                                  size: 36,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Comment Input
                      TextField(
                        controller: _reviewController,
                        decoration: InputDecoration(
                          hintText: "Share your experience...",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Image Picker Row
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.add_a_photo_rounded),
                            label: const Text("Add Photo"),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF041D66),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: const Color(0xFF041D66).withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _reviewImages.length,
                                itemBuilder: (ctx, i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          Image.file(_reviewImages[i], width: 50, height: 50, fit: BoxFit.cover),
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF041D66),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: const Color(0xFF041D66).withOpacity(0.4),
                          ),
                          child: _isSubmittingReview 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Post Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      // Recent Reviews Title
                      Row(
                        children: [
                          const Icon(Icons.comment_rounded, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            "Recent Reviews",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Realtime Reviews List
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return const Text("Unable to load reviews.");
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ));
                          }

                          final allDocs = snapshot.data?.docs ?? [];
                          final docs = allDocs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['place_label'] == label;
                          }).toList();

                          docs.sort((a, b) {
                            final dataA = a.data() as Map<String, dynamic>;
                            final dataB = b.data() as Map<String, dynamic>;
                            final timeA = (dataA['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                            final timeB = (dataB['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                            return timeB.compareTo(timeA);
                          });
                          
                          if (docs.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 8),
                                  Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => Divider(height: 32, color: Colors.grey[100]),
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              return _buildReviewItem(
                                data['user_name'] ?? "Anonymous",
                                data['rating'] ?? 0, 
                                data['comment'] ?? ""
                              );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String user, int rating, String comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF041D66).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.isNotEmpty ? user[0].toUpperCase() : "?", 
              style: const TextStyle(color: Color(0xFF041D66), fontWeight: FontWeight.bold)
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 16,
                        color: Colors.amber[700],
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(comment, style: TextStyle(color: Colors.grey[700], height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}