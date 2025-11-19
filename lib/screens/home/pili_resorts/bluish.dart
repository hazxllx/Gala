import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BluishResortPage extends StatefulWidget {
  const BluishResortPage({super.key});

  @override
  State<BluishResortPage> createState() => _BluishResortPageState();
}

class _BluishResortPageState extends State<BluishResortPage> {
  bool isFavorited = false;
  int _currentImageIndex = 0;

  static const String kResortTitle = 'Bluish Resort';
  static const String kAddress = 'Zone 5, Tagbong Pili, Camarines Sur 4418';
  
  // All Bluish Resort Images
  static const List<String> kGalleryImages = [
    'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/bluish/bluish3.jpg',
    'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/bluish/bluish2.jpg',
    'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/bluish/bluish1.jpg',
  ];

  static const String kImage = 'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/bluish/bluish3.jpg';

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(kResortTitle)
        .get();

    if (!mounted) return;
    setState(() => isFavorited = doc.exists);
  }

  Future<void> _handleFavoriteToggle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(kResortTitle);

    if (!isFavorited) {
      await favoritesDoc.set({
        'imagePath': kImage,
        'subtitle': kAddress,
        'type': 'Resort',
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favoritesDoc.delete();
    }

    if (!mounted) return;
    setState(() => isFavorited = !isFavorited);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Image Carousel
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 500,
              width: double.infinity,
              child: Stack(
                children: [
                  // Image display
                  PageView.builder(
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemCount: kGalleryImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(kGalleryImages[index]),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.22),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Dot indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        kGalleryImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _currentImageIndex == index ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet content
          Positioned(
            top: 360,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create your best memories at Bluish Resort! Featuring a cafe, event venue, cottages, and rooms, this destination offers the perfect setting for relaxation and celebrations. For bookings and reservations, contact 09690260560.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.8,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Entrance Rates',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildEntranceRates(),
                    const SizedBox(height: 24),
                    const Text(
                      'Business Hours',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBusinessHoursShort(),
                    const SizedBox(height: 24),

                    // Actions
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {
                        // TODO: add maps/deeplink here
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/menu.png',
                      "View Bluish Resort's Amenities",
                      () {
                        // TODO: link to amenities if available
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/star_filled.png',
                      'Give it a rate',
                      () => _showRatingDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Title + address over the image
          Positioned(
            top: 260,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  kResortTitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        kAddress,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 13.6,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Back + Favorite
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 60,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: _handleFavoriteToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFavorited ? const Color(0xFF0D4776) : Colors.white,
                foregroundColor:
                    isFavorited ? Colors.white : const Color(0xFF075A9E),
                elevation: 4,
              ),
              icon: Icon(isFavorited ? Icons.check : Icons.favorite_border),
              label: Text(isFavorited ? 'Added' : 'Add to favorite'),
            ),
          ),
        ],
      ),
    );
  }

  /// Entrance rates for Pool 1 & Pool 2
  Widget _buildEntranceRates() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: const [
              Icon(Icons.pool, size: 20, color: Color(0xFF1556B1)),
              SizedBox(width: 8),
              Text(
                'Pool 1 & Pool 2 Access',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day rate
          _buildRateRow('Daytime (7:00 AM - 5:00 PM)', '₱100/head'),
          const SizedBox(height: 12),
          // Night rate
          _buildRateRow('Night time (6:00 PM - 5:00 AM)', '₱150/head'),
          const SizedBox(height: 16),
          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, 
                    size: 18, color: Color(0xFF1556B1)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kids and adults are charged the same rate',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1556B1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateRow(String time, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            time,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1556B1),
          ),
        ),
      ],
    );
  }

  /// Business hours - always open
  Widget _buildBusinessHoursShort() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        children: [
          // Open badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1556B1),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                child: const Text(
                  'Open now',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Always open line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.access_time, size: 18, color: Color(0xFF1556B1)),
              SizedBox(width: 6),
              Text(
                'Open 24/7 · Every Day',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B1A2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTileWithArrow(
    BuildContext context,
    String imagePath,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(imagePath, width: 28, height: 28, fit: BoxFit.contain),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int selected = 0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: const Color(0xFFF8F8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rate Bluish Resort',
                    style: TextStyle(
                      color: Color(0xFF0B55A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < selected ? Icons.star : Icons.star_border,
                          color: i < selected
                              ? const Color(0xFF0B55A0)
                              : Colors.amber,
                          size: 36,
                        ),
                        splashRadius: 24,
                        onPressed: () => setState(() => selected = i + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF0B55A0),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (selected > 0 && !isSubmitting)
                              ? () async {
                                  setState(() => isSubmitting = true);
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final ratingRef = FirebaseFirestore.instance
                                        .collection('resorts')
                                        .doc(kResortTitle)
                                        .collection('ratings')
                                        .doc(user.uid);
                                    await ratingRef
                                        .set({'rating': selected});
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(dialogContext)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Thanks for rating Bluish Resort!'),
                                          backgroundColor:
                                              Color(0xFF0B55A0),
                                        ),
                                      );
                                    }
                                  }
                                  if (context.mounted) {
                                    setState(() => isSubmitting = false);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (selected > 0)
                                ? const Color(0xFF0B55A0)
                                : Colors.grey[300],
                            foregroundColor: (selected > 0)
                                ? Colors.white
                                : Colors.grey,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
