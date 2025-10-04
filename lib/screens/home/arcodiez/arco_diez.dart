import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'arcodiez_menu.dart';
import 'arcodiez_route.dart';
import 'arcodiez_reviews.dart';

class ArcoDiezPage extends StatefulWidget {
  const ArcoDiezPage({super.key});

  @override
  State<ArcoDiezPage> createState() => _ArcoDiezPageState();
}

class _ArcoDiezPageState extends State<ArcoDiezPage> {
  bool isFavorited = false;
  int selectedStars = 0;

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
          .doc('Arco Diez Cafe')
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
        .doc('Arco Diez Cafe');

    if (!isFavorited) {
      await favoritesDoc.set({
        'imagePath': 'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_diez.jpeg',
        'subtitle': 'Km. 10 Pacol Rd',
        'rating': 5,
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
          Positioned(
            top: -70,
            left: 0,
            right: 0,
            child: Container(
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_diez.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),
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
                      'Arco Diez Cafe is a cozy, family-friendly spot in Pacol, Naga City, serving farm-to-cup coffee and homemade dishes. '
                      'Committed to quality, transparency, and sustainability, the cafe values the hard work of coffee farmers while providing '
                      'a relaxing space for customers to enjoy great coffee and food.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.normal,
                        fontSize: 11.8,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
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
                    SizedBox(
                      height: 105,
                      child: Row(
                        children: [
                          _buildClosedBox(),
                          const SizedBox(width: 16),
                          _buildOpenBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RoutePage()),
                        );
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/menu.png',
                      'View Arco Diez\'s Menu',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuPage(),
                          ),
                        );
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/star_filled.png',
                      'Give it a rate',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPage(cafeTitle: "Arco Diez Cafe"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arco Diez Cafe',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: const Text(
                        'Km. 10 Pacol Rd, Naga City, 4400 Camarines Sur',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
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
              ),
              icon: Icon(isFavorited ? Icons.check : Icons.favorite_border),
              label: Text(isFavorited ? 'Added' : 'Add to favorite'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBox() {
    return Flexible(
      flex: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: const Center(
                child: Text(
                  'Closed',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Monday', style: _dayTextStyleHighlighted()),
                    const SizedBox(height: 4),
                    Text('Tuesday', style: _dayTextStyleHighlighted()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenBox() {
    return Flexible(
      flex: 7,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 10, 70, 144),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: const Center(
                child: Text(
                  'Open',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('10AM - 9PM', style: _openTimeTextStyle()),
                      const SizedBox(height: 4),
                      Text('Wed to Fri', style: _dayTextStyleSmall()),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('7AM - 9PM', style: _openTimeTextStyle()),
                      const SizedBox(height: 4),
                      Text('Sat & Sun', style: _dayTextStyleSmall()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  TextStyle _dayTextStyleSmall() {
    return const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.black54);
  }

  TextStyle _openTimeTextStyle() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
  }

  TextStyle _dayTextStyleHighlighted() {
    return const TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    );
  }
}
