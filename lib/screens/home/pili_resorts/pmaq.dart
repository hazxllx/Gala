import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PmaqVilleResortPage extends StatefulWidget {
  const PmaqVilleResortPage({super.key});

  @override
  State<PmaqVilleResortPage> createState() => _PmaqVilleResortPageState();
}

class _PmaqVilleResortPageState extends State<PmaqVilleResortPage> {
  bool isFavorited = false;
  int _currentImageIndex = 0;

  static const String kResortTitle = 'PMAQ Ville Resort';
  static const String kAddress =
      'Zone 3, PROSAMAPI, Palestina Pili, Philippines';

  static const List<String> kGalleryImages = [
    'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/pmaq/pmaq1.jpg',
    'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/pmaq/pmaq.jpg',
  ];

  static const String kImage =
      'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_resorts/pmaq/pmaq1.jpg';

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
    // Determine colors based on theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtextColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // IMAGE CAROUSEL
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 500,
              width: double.infinity,
              child: Stack(
                children: [
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

                  // DOTS
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

          // CONTENT BODY
          Positioned(
            top: 360,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ABOUT
                    Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Unwind and refresh your spirit at PMAQ Ville Resort—a tranquil haven where relaxation takes center stage. It’s the perfect spot to escape daily stress and experience true peace.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: subtextColor,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ⭐ NEW OPERATING HOURS CARD
                    _buildOperatingHoursCard(isDarkMode),
                    const SizedBox(height: 28),

                    // ENTRANCE RATES
                    _buildEntranceRatesPmaq(isDarkMode),
                    const SizedBox(height: 40),

                    // ACTION BUTTONS
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {},
                      isDarkMode,
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/menu.png',
                      "View PMAQ's Amenities",
                      () {},
                      isDarkMode,
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/star_filled.png',
                      'Give it a rate',
                      () => _showRatingDialog(context, isDarkMode),
                      isDarkMode,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TITLE + ADDRESS
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

          // BACK BUTTON
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // FAVORITE BUTTON
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

  // OPERATING HOURS CARD
  Widget _buildOperatingHoursCard(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Business Hours",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FC),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B55A0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: const Center(
                  child: Text(
                    "Open",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      "7:00 AM – 6:00 PM",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : const Color(0xFF0B1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Everyday",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ENTRANCE RATES CARD
  Widget _buildEntranceRatesPmaq(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: isDarkMode ? null : Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pool, size: 20, color: Color(0xFF1556B1)),
              const SizedBox(width: 8),
              Text(
                'Entrance Rates',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : const Color(0xFF0B1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Daytime 7:00 AM - 5:00 PM',
            style: TextStyle(
              color: Color(0xFF1556B1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _buildRateRow('Adult (13yrs old above)', '₱250', isDarkMode),
          const SizedBox(height: 8),
          _buildRateRow('Kids (6–12yrs old)', '₱180', isDarkMode),
          const SizedBox(height: 8),
          _buildRateRow('Kids (1–5yrs old)', 'FREE', isDarkMode),
          const SizedBox(height: 25),
          const Text(
            'Night Time 6:00 PM - 7:00 AM',
            style: TextStyle(
              color: Color(0xFF1556B1),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          _buildRateRow('Adult (13yrs old above)', '₱250', isDarkMode),
          const SizedBox(height: 8),
          _buildRateRow('Kids (6–12yrs old)', '₱180', isDarkMode),
          const SizedBox(height: 8),
          _buildRateRow('Kids (1–5yrs old)', 'FREE', isDarkMode),
        ],
      ),
    );
  }

  // RATE ROW HELPER
  Widget _buildRateRow(String name, String price, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white70 : const Color(0xFF4A5568),
            ),
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1556B1),
          ),
        ),
      ],
    );
  }

  // ACTION TILE
  Widget _buildOptionTileWithArrow(
    BuildContext context,
    String imagePath,
    String text,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDarkMode)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: isDarkMode ? Colors.white70 : Colors.black45, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // RATING DIALOG
  void _showRatingDialog(BuildContext context, bool isDarkMode) {
    int selected = 0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rate $kResortTitle',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFF0B55A0),
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
                        onPressed: () =>
                            setState(() => selected = i + 1),
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
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : const Color(0xFF0B55A0),
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
                          onPressed:
                              (selected > 0 && !isSubmitting)
                                  ? () async {
                                      setState(() => isSubmitting = true);
                                      final user = FirebaseAuth
                                          .instance.currentUser;
                                      if (user != null) {
                                        final ratingRef = FirebaseFirestore
                                            .instance
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
                                                  'Thanks for rating!'),
                                              backgroundColor:
                                                  Color(0xFF0B55A0),
                                            ),
                                          );
                                        }
                                      }

                                      if (context.mounted) {
                                        setState(
                                            () => isSubmitting = false);
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
