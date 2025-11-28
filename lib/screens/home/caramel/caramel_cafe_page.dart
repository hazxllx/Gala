import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Caramel Cafe Page
class CaramelCafePage extends StatefulWidget {
  const CaramelCafePage({super.key});

  @override
  State<CaramelCafePage> createState() => _CaramelCafePageState();
}

class _CaramelCafePageState extends State<CaramelCafePage> {
  bool isFavorited = false;
  PageController _pageController = PageController();
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
      if (mounted) {
        setState(() {
          isFavorited = doc.exists;
        });
      }
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

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ======================
          // HERO IMAGE CAROUSEL
          // ======================
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
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
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
                  // IMAGE INDICATORS
                  Positioned(
                    bottom: 30,
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
                  ),
                ],
              ),
            ),
          ),

          // ===========================
          // BOTTOM SHEET CONTENT
          // ===========================
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
                    // About Section
                    const Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Caramel Café welcomes you with wholehearted goodness through its cozy atmosphere and crafted treats.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.8,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Business Hours Section
                    const Text(
                      'Business Hours',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildBusinessHours(),
                    const SizedBox(height: 24),

                    // Options
                    _buildOptionTile(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {},
                    ),
                    _buildOptionTile(
                      context,
                      'assets/icons/menu.png',
                      "View Caramel Cafe's Menu",
                      () {},
                    ),
                    _buildOptionTile(
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

          // ======================
          // TITLE OVERLAY
          // ======================
          const Positioned(
            top: 260,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caramel Cafe',
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
                        'Diversion Road, Naga City (In front of Bennett’s Plaza)',
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
                backgroundColor: isFavorited
                    ? const Color.fromARGB(255, 150, 70, 50)
                    : Colors.white,
                foregroundColor:
                    isFavorited ? Colors.white : const Color(0xFF8B4A2B),
                elevation: 4,
              ),
              icon: Icon(
                isFavorited ? Icons.check : Icons.favorite_border,
              ),
              label: Text(isFavorited ? 'Added' : 'Add to favorite'),
            ),
          ),
        ],
      ),
    );
  }

  // Business Hours Widget (Uniform schedule)
  Widget _buildBusinessHours() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1556B1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: const Center(
              child: Text(
                "Open",
                style: TextStyle(
                  fontFamily: "Inter",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          // Uniform Hours
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: const [
                Text(
                  "10AM - 10PM",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Open daily",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
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

  // Rating Dialog
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rate Caramel Cafe',
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
                              : Colors.amber[400],
                          size: 36,
                        ),
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
                                            'Thanks for rating Caramel Cafe!'),
                                        backgroundColor: Color(0xFF0B55A0),
                                      ),
                                    );
                                  }

                                  if (mounted) {
                                    setState(() => isSubmitting = false);
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selected > 0
                                ? const Color(0xFF0B55A0)
                                : Colors.grey[300],
                            foregroundColor:
                                selected > 0 ? Colors.white : Colors.grey,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
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
