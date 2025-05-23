import 'package:flutter/material.dart';
import 'package:my_app/arco_diez/arcodiez_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: const ArcoDiezPage(),
    );
  }
}

class ArcoDiezPage extends StatefulWidget {
  const ArcoDiezPage({super.key});

  @override
  State<ArcoDiezPage> createState() => _ArcoDiezPageState();
}

class _ArcoDiezPageState extends State<ArcoDiezPage> {
  bool isFavorited = false;
  int selectedStars = 0; // <--- THIS for rating selection

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
                  image: AssetImage('assets/images/arco_diez.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2),
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
                    SizedBox(
                      height: 105,
                      child: Row(
                        children: [
                          _buildClosedBox(),
                          SizedBox(width: 16),
                          _buildOpenBox(),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Option Tiles
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/location.png',
                      'Go to Location and More Details',
                      () {
                        // TODO: Add navigation here if needed
                      },
                    ),
                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/menu.png',
                      'View Arco Diez’s Menu',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuPage(),
                          ),
                        );
                      },
                    ),
                    // Give it a rate (with interactive stars beside)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 16,
                        ),
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
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Give it a rate',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedStars = index + 1;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Image.asset(
                                      selectedStars > index
                                          ? 'assets/icons/star_filled.png'
                                          : 'assets/icons/star_gray.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildOptionTileWithArrow(
                      context,
                      'assets/icons/events.png',
                      'See upcoming events',
                      () {},
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
                  'Arco Diez Cafe',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Km. 10 Pacol Rd, Naga, 4400 Camarines Sur',
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

          // Back Button
          Positioned(
            top: 70,
            left: 24,
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Favorite Button with toggle
          Positioned(
            top: 60,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isFavorited = !isFavorited;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFavorited
                        ? const Color.fromARGB(255, 13, 71, 118)
                        : Colors.white, // <-- bg color change
                foregroundColor:
                    isFavorited
                        ? Colors.white
                        : Color.fromARGB(
                          255,
                          7,
                          90,
                          158,
                        ), // <-- text and icon color change
              ),
              icon: Icon(isFavorited ? Icons.check : Icons.favorite_border),
              label: Text(isFavorited ? 'Added' : 'Add to favorite'),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildClosedBox() {
    return Flexible(
      flex: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
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
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
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
                    Text('Monday', style: _dayTextStyleSmall()),
                    SizedBox(height: 4),
                    Text('Tuesday', style: _dayTextStyleSmall()),
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
          boxShadow: [
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
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 10, 70, 144),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
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
                      SizedBox(height: 4),
                      Text('Wed to Fri', style: _dayTextStyleSmall()),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('7AM - 9PM', style: _openTimeTextStyle()),
                      SizedBox(height: 4),
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

  TextStyle _dayTextStyleSmall() {
    return TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.black54);
  }

  TextStyle _openTimeTextStyle() {
    return TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
  }
}
