import 'package:flutter/material.dart';
import 'package:my_project/services/firebase_storage_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // Required for bbox calculations
import 'dart:io'; // For File
// Firebase Imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added Auth
import 'package:image_picker/image_picker.dart';


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
  
  // State
  Position? _currentPosition;
  bool _isLoading = false;
  
  // Filters
  final List<String> _categories = [
    "Coffee", 
    "Park", 
    "Hotel", 
    "Bank", 
    "Restaurant",
    "Gas Station"
  ];
  String _selectedCategory = "Coffee";
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
    _initWebView();
  }

  @override
  void dispose() {
    _reviewController.dispose();
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
            _getCurrentLocation();
          },
          onWebResourceError: (error) {
            debugPrint("Map Resource Error: ${error.description}");
          },
        ),
      )
      // Make sure this matches your asset file name exactly
      ..loadFlutterAsset('assets/aws_map.html');
  }

  // --- 1. Location & API Logic ---

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showError("Location services disabled");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showError("Location permission denied");
        return;
      }
    }

    try {
      // Changed to use LocationAccuracy.best for better pin accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      
      if (!mounted) return;
      
      setState(() => _currentPosition = position);

      // Update map center using the unified function name
      _webViewController.runJavaScript(
        'updateStartLocation(${position.latitude}, ${position.longitude})',
      );

      // Perform initial search
      _searchNearbyPlaces();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _searchNearbyPlaces() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://places.geo.$_AWS_REGION.amazonaws.com/places/v0/indexes/$_PLACE_INDEX/search/text?key=$_API_KEY',
    );

    try {
      // Calculate Bounding Box for filtering (approximate)
      double lat = _currentPosition!.latitude;
      double lon = _currentPosition!.longitude;
      // 1 degree lat ~ 111km
      double latOffset = _radiusKm / 111.0;
      // 1 degree lon ~ 111km * cos(lat)
      double lonOffset = _radiusKm / (111.0 * cos(lat * (pi / 180.0)));

      List<double> bbox = [
        lon - lonOffset, // min Lon
        lat - latOffset, // min Lat
        lon + lonOffset, // max Lon
        lat + latOffset, // max Lat
      ];

      final body = jsonEncode({
        "Text": _selectedCategory,
        // REMOVED BiasPosition to resolve API conflict with FilterBBox
        "FilterBBox": bbox,
        "MaxResults": 50, // Increased to catch more relevant places
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
          
          final distMeters = Geolocator.distanceBetween(
            lat,
            lon,
            pLat,
            pLon,
          );

          // Double check radius (BBox is square, radius is circle)
          if (distMeters <= (_radiusKm * 1000)) {
            validPlaces.add({
              'id': place['PlaceId'] ?? place['Label'], // Attempt to capture ID or use Label
              'label': place['Label'] ?? "Unknown Place",
              'lat': pLat,
              'lon': pLon,
              'dist': distMeters,
              'categories': place['Categories'] ?? [],
            });
          }
        }

        // --- Safe JSON passing ---
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

    // Split name and mask parts: "John Doe" -> "J*** D***"
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
      // 1. Upload Images
      List<String> imageUrls = [];
      if (_reviewImages.isNotEmpty) {
        imageUrls = await FirebaseStorageService.uploadEstablishmentImages(_reviewImages);
      }

      // 2. Get User Info
      final user = FirebaseAuth.instance.currentUser;
      final anonymizedName = _getAnonymizedName();

      // 3. Save Review to Firestore
      await FirebaseFirestore.instance.collection('reviews').add({
        'place_label': _selectedPlace!['label'],
        'place_id': _selectedPlace!['id'],
        'rating': _rating,
        'comment': _reviewController.text.trim(),
        'images': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': user?.uid,
        'user_name': anonymizedName, // Save the anonymized name
      });

      // 4. Reset Form & UI (Do NOT close the card)
      setState(() {
        _rating = 0;
        _reviewController.clear();
        _reviewImages.clear();
        _isSubmittingReview = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
        // Do NOT close the card so user can see their review appear
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
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _onPlaceTapped(Map<String, dynamic> place) {
    setState(() {
      _selectedPlace = place;
      _isCardVisible = true;
      // Reset review state when opening a new place
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          WebViewWidget(controller: _webViewController),

          // 2. Filter Bar (Top)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _categories.map((cat) {
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
                // Radius Slider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text("Range: ${_radiusKm.toStringAsFixed(1)} km"),
                      Expanded(
                        child: Slider(
                          value: _radiusKm,
                          min: 1.0,
                          max: 10.0,
                          divisions: 9,
                          activeColor: Colors.redAccent,
                          onChanged: (val) {
                            setState(() => _radiusKm = val);
                          },
                          onChangeEnd: (val) => _searchNearbyPlaces(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Loading Indicator
          if (_isLoading)
            const Positioned(
              top: 160,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 30, 
                  height: 30, 
                  child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 3),
                ),
              ),
            ),

          // 4. Slide-up Info Card
          if (_isCardVisible && _selectedPlace != null)
            DraggableScrollableSheet(
              initialChildSize: 0.45, // Slightly taller for review inputs
              minChildSize: 0.2,     
              maxChildSize: 0.95,    
              builder: (context, scrollController) {
                final label = _selectedPlace!['label'] as String;
                final name = label.split(',')[0];
                final address = label.replaceAll('$name, ', '');
                final distance = (_selectedPlace!['dist'] as double).toStringAsFixed(0);

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _closeCard,
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Tags/Status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Open Now",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$distance m away",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Address
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(address, style: const TextStyle(fontSize: 16))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),

                      // --- RATE & REVIEW SECTION ---
                      const Text(
                        "Rate & Review",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      
                      // Star Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () {
                              setState(() => _rating = index + 1);
                            },
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      
                      // Comment Input
                      TextField(
                        controller: _reviewController,
                        decoration: const InputDecoration(
                          hintText: "Share your experience...",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),

                      // Image Picker Row
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Add Photo"),
                          ),
                          const SizedBox(width: 10),
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
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.file(_reviewImages[i], width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: _isSubmittingReview 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Post Review"),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      
                      // Recent Reviews Title
                      const Text(
                        "Recent Reviews",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      
                      // Realtime Reviews List
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('reviews')
                            .snapshots(), // FIX: Simple query to avoid index errors (Rule 2)
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Unable to load reviews."),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // Client-side Filtering & Sorting
                          final allDocs = snapshot.data?.docs ?? [];
                          
                          // Filter by current place label
                          final docs = allDocs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['place_label'] == label;
                          }).toList();

                          // Sort by timestamp descending (newest first)
                          docs.sort((a, b) {
                            final dataA = a.data() as Map<String, dynamic>;
                            final dataB = b.data() as Map<String, dynamic>;
                            // Handle null timestamps (e.g. pending writes)
                            final timeA = (dataA['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                            final timeB = (dataB['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                            return timeB.compareTo(timeA);
                          });
                          
                          if (docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text("No reviews yet. Be the first!", style: TextStyle(color: Colors.grey)),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Important inside parent ScrollView
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              return _buildReviewItem(
                                data['user_name'] ?? "Anonymous", // Use saved anonymized name
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Text(user.isNotEmpty ? user[0] : "?", style: const TextStyle(color: Colors.black)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}