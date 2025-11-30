import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'CaramelMenuPage.dart';

class CaramelCafePage extends StatefulWidget {
  const CaramelCafePage({super.key});

  @override
  State<CaramelCafePage> createState() => _CaramelCafePageState();
}

class _CaramelCafePageState extends State<CaramelCafePage> {
  bool isFavorited = false;
  final PageController _pageController = PageController();
  int currentImageIndex = 0;

  final List<String> images = [
    "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel.jpg",
    "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel1.jpg"
  ];

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  void _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('Caramel Cafe')
          .get();

      if (mounted) setState(() => isFavorited = doc.exists);
    }
  }

  Future<void> _handleFavoriteToggle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc('Caramel Cafe');

    if (!isFavorited) {
      await favoritesDoc.set({
        'imagePath': images.first,
        'subtitle': 'Diversion Road, Naga City (In front of Bennett’s Plaza)',
        'type': 'Cafe',
        'addedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await favoritesDoc.delete();
    }

    setState(() => isFavorited = !isFavorited);
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: page),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor =
        isDark ? Colors.grey[400]! : const Color.fromARGB(221, 52, 52, 52);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // HERO IMAGE
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 500,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) {
                      setState(() => currentImageIndex = i);
                    },
                    itemBuilder: (context, i) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(images[i]),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(isDark ? 0.35 : 0.22),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: currentImageIndex == i ? 24 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: currentImageIndex == i
                                ? Colors.white
                                : Colors.white54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // CONTENT AREA
          Positioned(
            top: 360,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
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
                      "Caramel Café welcomes you with wholehearted goodness through its cozy atmosphere and crafted treats.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: subtitleColor,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // HOURS
                    Text(
                      'Business Hours',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBusinessHours(isDark),

                    const SizedBox(height: 28),

                    // OPTION TILES
                    _buildOptionTile(
                      isDark,
                      context,
                      'assets/icons/location.png',
                      "Go to Location and More Details",
                      () {},
                    ),

                    _buildOptionTile(
                      isDark,
                      context,
                      'assets/icons/menu.png',
                      "View Caramel Cafe's Menu",
                      () {
                        Navigator.push(
                          context,
                          _fadeRoute(const CaramelMenuPage()),
                        );
                      },
                    ),

                    _buildOptionTile(
                      isDark,
                      context,
                      'assets/icons/star_filled.png',
                      "Give it a rate",
                      () => _showRatingDialog(context, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TITLE OVERLAY
          Positioned(
            top: 260,
            left: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caramel Cafe',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 260,
                      child: Text(
                        'Diversion Road, Naga City (In front of Bennett’s Plaza)',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.6,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
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
                elevation: 5,
                foregroundColor:
                    isFavorited ? Colors.white : const Color(0xFF075A9E),
              ),
              icon: Icon(
                isFavorited ? Icons.check : Icons.favorite_border,
                color: isFavorited ? Colors.white : const Color(0xFF075A9E),
              ),
              label: Text(
                isFavorited ? "Added" : "Add to favorite",
                style: TextStyle(
                  color: isFavorited ? Colors.white : const Color(0xFF075A9E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BUSINESS HOURS WIDGET
  Widget _buildBusinessHours(bool isDark) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.transparent : const Color(0xFFE5E9F2),
        ),
        boxShadow: [
          if (!isDark)
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
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF1556B1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Text(
              "Open",
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "10AM - 10PM",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Open daily",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ⭐ UPDATED OPTION TILE (EXACT COLOR MATCH)
  Widget _buildOptionTile(
    bool isDark,
    BuildContext context,
    String iconPath,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isDark ? const Color.fromARGB(255, 42, 42, 42) : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 26, height: 26),
            const SizedBox(width: 18),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 24,
              color: isDark ? const Color(0xFF7A7A7A) : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // RATING DIALOG
  void _showRatingDialog(BuildContext context, bool isDark) {
    int selected = 0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            final Color dialogColor =
                isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F8FF);

            return Dialog(
              backgroundColor: dialogColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rate Caramel Cafe',
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF0B55A0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 22),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (i) => IconButton(
                          icon: Icon(
                            i < selected ? Icons.star : Icons.star_border,
                            size: 36,
                            color: i < selected
                                ? const Color(0xFF0B55A0)
                                : Colors.amber,
                          ),
                          onPressed: () => setState(() => selected = i + 1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0B55A0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selected == 0
                                ? null
                                : () async {
                                    setState(() => isSubmitting = true);

                                    final user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await FirebaseFirestore.instance
                                          .collection('cafes')
                                          .doc('Caramel Cafe')
                                          .collection('ratings')
                                          .doc(user.uid)
                                          .set({'rating': selected});
                                    }

                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(dialogContext)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Thanks for rating Caramel Cafe!"),
                                          backgroundColor: Color(0xFF0B55A0),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B55A0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
