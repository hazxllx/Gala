import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Uncomment and update imports with your actual review/menu/route screens
// import 'harina_menu.dart';
// import 'harina_route.dart';
// import 'harina_reviews.dart';

class HarinaCafePage extends StatefulWidget {
  const HarinaCafePage({super.key});

  @override
  State<HarinaCafePage> createState() => _HarinaCafePageState();
}

class _HarinaCafePageState extends State<HarinaCafePage> {
  bool isFavorited = false;

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
          .doc('Harina Cafe')
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
        .doc('Harina Cafe');

    if (!isFavorited) {
      // Add to favorites
      await favoritesDoc.set({
        'imagePath': 'assets/harina_cafe.jpeg',
        'subtitle': 'Narra St. Mariano Village, Magsaysay Ave., Naga City, Camarines Sur',
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
          // Background Image
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/harina_cafe.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.22),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // Scrollable White Container
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
                    Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Harina Cafe is a pastry-focused cafe that offers a wide range of food and beverages. From coffees to milkbase; from pastas to pastries. The soothing ambience of the cafe is something to see for yourself.",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 12.3,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Business Hours
                    Text(
                      'Business Hours',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 18),

                    // Business Hours Row
                    _buildBusinessHours(),

                    SizedBox(height: 24),

                    // Option Tiles
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {
                        // TODO: Push to your location page
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => HarinaRoutePage()));
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/menu.png',
                      "View Harina Cafe's Menu",
                      () {
                        // TODO: Push to your menu page
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => HarinaMenuPage()));
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/star_filled.png',
                      'Give it a rate',
                      () {
                        // TODO: Push to your review page
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => HarinaReviewPage(cafeTitle: "Harina Cafe")));
                        _showRatingDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cafe Name and Address
          Positioned(
            top: 260,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harina Cafe',
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
                        'Narra St. Mariano Village, Magsaysay Ave., Naga City, Camarines Sur',
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

          // Back Button
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Favorite Button with Firestore
          Positioned(
            top: 60,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () async {
                await _handleFavoriteToggle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFavorited
                    ? const Color.fromARGB(255, 13, 71, 118)
                    : Colors.white,
                foregroundColor: isFavorited
                    ? Colors.white
                    : const Color.fromARGB(255, 7, 90, 158),
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

  Widget _buildBusinessHours() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1556B1),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 4),
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
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHoursColumn("11AM-11PM", "Monday"),
              _buildHoursColumn("10AM - 11PM", "Tuesday - Saturday"),
              _buildHoursColumn("9AM - 11PM", "Sunday"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursColumn(String hours, String day) {
    return Expanded(
      child: Column(
        children: [
          Text(
            hours,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 3),
          Text(
            day,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.1,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
            boxShadow: [
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
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.black45, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  // --- Rating dialog (minimal, demo only) ---
  void _showRatingDialog(BuildContext context) {
    int selected = 0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Color(0xFFF8F8FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rate Harina Cafe',
                    style: TextStyle(
                      color: Color(0xFF0B55A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < selected ? Icons.star : Icons.star_border,
                          color: i < selected
                              ? Color(0xFF0B55A0)
                              : Colors.amber[400],
                          size: 36,
                        ),
                        splashRadius: 24,
                        onPressed: () => setState(() {
                          selected = i + 1;
                        }),
                      );
                    }),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          child: Text(
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
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (selected > 0 && !isSubmitting)
                              ? () async {
                                  setState(() => isSubmitting = true);
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    final ratingRef = FirebaseFirestore.instance
                                        .collection('cafes')
                                        .doc('Harina Cafe')
                                        .collection('ratings')
                                        .doc(user.uid);
                                    await ratingRef.set({'rating': selected});
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Thanks for rating Harina Cafe!'),
                                        backgroundColor: Color(0xFF0B55A0),
                                      ),
                                    );
                                  }
                                  setState(() => isSubmitting = false);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (selected > 0)
                                ? Color(0xFF0B55A0)
                                : Colors.grey[300],
                            foregroundColor: (selected > 0)
                                ? Colors.white
                                : Colors.grey,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: isSubmitting
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.2,
                                  ),
                                )
                              : Text(
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
