import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Google Fonts import removed
import 'package:my_project/screens/home/cafe.dart' as naga;
import 'package:my_project/screens/home/directions_screen.dart';
import 'package:my_project/screens/home/nearby.dart';
import 'package:my_project/screens/home/pili_cafe/pili_cafe.dart' as pili;
import 'package:my_project/screens/home/naga_bars.dart' as bars;
import 'package:my_project/screens/home/pili_resorts.dart';
import 'package:my_project/screens/home/naga_parks.dart';
import 'package:my_project/screens/home/header.dart';
import 'package:my_project/screens/demomap.dart';

class CategoryScreen extends StatefulWidget {
  final String locationName;

  const CategoryScreen({super.key, required this.locationName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCategories = [];
  final List<Map<String, dynamic>> allCategories = [];
  User? user;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;

    allCategories.addAll([
      {
        "image": 'assets/cafe.png',
        "name": "Cafes",
        "onTap": (BuildContext context, String locationName) {
          if (locationName.toLowerCase().contains('pili')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    pili.CafePage(locationName: locationName),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    naga.CafePage(locationName: locationName),
              ),
            );
          }
        },
      },
      {
        "image": 'assets/beach.png',
        "name": "Resorts",
        "onTap": (BuildContext context, String locationName) {
          if (locationName.toLowerCase().contains('pili')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResortsPage(locationName: locationName),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resorts for $locationName coming soon 🏖️'),
                backgroundColor: Colors.blueAccent,
              ),
            );
          }
        },
      },
      {
        "image": 'assets/parks.png',
        "name": "Parks",
        "onTap": (BuildContext context, String locationName) {
          if (locationName.toLowerCase().contains('naga')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParksPage(locationName: locationName),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Parks for $locationName coming soon 🌳'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          }
        },
      },
      {
        "image": 'assets/restaurant.png',
        "name": "Restaurants",
        "onTap": (BuildContext context, String locationName) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Restaurants for $locationName coming soon 🍽️'),
            ),
          );
        },
      },
      {
        "image": 'assets/inuman.png',
        "name": "Bars",
        "onTap": (BuildContext context, String locationName) {
          if (locationName.toLowerCase().contains('naga')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    bars.BarsPage(locationName: locationName),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bars not available for $locationName yet'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      },
    ]);

    filteredCategories = List.from(allCategories);

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredCategories = allCategories
            .where(
              (cat) =>
                  cat['name'].toString().toLowerCase().contains(query),
            )
            .toList();
      });
    });
  }

  void _sortCategories(String sortType) {
    setState(() {
      if (sortType == 'A-Z') {
        filteredCategories.sort(
          (a, b) => a['name']
              .toString()
              .toLowerCase()
              .compareTo(b['name'].toString().toLowerCase()),
        );
      } else if (sortType == 'Z-A') {
        filteredCategories.sort(
          (a, b) => b['name']
              .toString()
              .toLowerCase()
              .compareTo(a['name'].toString().toLowerCase()),
        );
      }
    });
  }

  // --- MODERN FARE DIALOG (No Google Fonts) ---
  void _showFareDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D9CDB).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: Color(0xFF2D9CDB),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Transport & Fare",
                        style: TextStyle( // Replaced GoogleFonts with TextStyle
                          fontSize: 22,
                          fontWeight: FontWeight.bold, // Bold for emphasis
                          color: titleColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tricycle Section
                _buildModernFareCard(
                  icon: Icons.electric_rickshaw_rounded, // Or Icons.moped
                  iconColor: Colors.orange,
                  title: "Tricycle",
                  regularPrice: "15",
                  discountedPrice: "12",
                  isDark: isDark,
                  cardColor: cardColor,
                  titleColor: titleColor,
                ),
                
                const SizedBox(height: 16),

                // Jeep Section
                _buildModernFareCard(
                  icon: Icons.directions_bus_filled_rounded,
                  iconColor: Colors.blueAccent,
                  title: "Jeep",
                  regularPrice: "13",
                  discountedPrice: "11",
                  isDark: isDark,
                  cardColor: cardColor,
                  titleColor: titleColor,
                ),

                const SizedBox(height: 24),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    ),
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernFareCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String regularPrice,
    required String discountedPrice,
    required bool isDark,
    required Color cardColor,
    required Color titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle( // Replaced GoogleFonts with TextStyle
                  fontSize: 18,
                  color: titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceRow("Regular", regularPrice, isDark),
          const SizedBox(height: 8),
          _buildPriceRow("Student, Senior, PWD", discountedPrice, isDark),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "₱$price",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final bgColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: GalaHeader(userPhotoUrl: user?.photoURL),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // SEARCH BAR
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color:
                      isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style:
                          TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () => _searchController.clear(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.close,
                            size: 16, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "Where do you want to go?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: _sortCategories,
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) => const [
                    PopupMenuItem<String>(
                      value: 'A-Z',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 16),
                          SizedBox(width: 8),
                          Text('Sort A–Z'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Z-A',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 16),
                          SizedBox(width: 8),
                          Text('Sort Z–A'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          "Sort by",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredCategories.map((category) {
                  final String name = category['name'] as String;

                  final Color accent = name == 'Cafes'
                      ? (isDarkMode
                          ? const Color.fromARGB(255, 244, 194, 171)
                          : const Color.fromARGB(255, 184, 101, 71))
                      : name == 'Bars'
                          ? (isDarkMode
                              ? const Color.fromARGB(255, 149, 239, 167)
                              : const Color.fromARGB(255, 31, 166, 35))
                          : name == 'Beach'
                              ? (isDarkMode
                                  ? const Color.fromARGB(255, 162, 208, 255)
                                  : const Color(0xFF1A73E8))
                              : name == 'Parks'
                                  ? (isDarkMode
                                      ? const Color.fromARGB(255, 176, 231, 185)
                                      : const Color(0xFF2E7D32))
                                  : (isDarkMode
                                      ? const Color.fromARGB(255, 174, 151, 255)
                                      : const Color.fromARGB(255, 44, 13, 98));

                  return Row(
                    children: [
                      CategoryCard(
                        image: category['image'] as String,
                        name: name,
                        onTap: () {
                          if (category.containsKey('onTap')) {
                            category['onTap'](
                                context, widget.locationName);
                          }
                        },
                        isDarkMode: isDarkMode,
                        textColor: accent,
                      ),
                      const SizedBox(width: 12),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "What do you want to do?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),

            const SizedBox(height: 16),
            const SizedBox(height: 8),
            ActionButton(
                icon: 'assets/nearby.png',
                label: "Find nearby places",
                isDarkMode: isDarkMode),
            const SizedBox(height: 12),
            ActionButton(
              icon: 'assets/directions.png',
              label: "Get directions",
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // --- CHECK FARE BUTTON ---
            ActionButton(
              icon: 'assets/fare.png',
              label: "Check public transport & fare",
              isDarkMode: isDarkMode,
              onTap: () {
                if (widget.locationName.toLowerCase().contains('naga')) {
                  _showFareDialog(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Fare info available for Naga only. Current: ${widget.locationName}'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// CATEGORY CARD
class CategoryCard extends StatefulWidget {
  final String image;
  final String name;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double width;
  final double height;
  final Color textColor;

  const CategoryCard({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
    required this.isDarkMode,
    required this.textColor,
    this.width = 155,
    this.height = 173,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  double scale = 1.0;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
          border: Border.all(
            color:
                widget.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                widget.image,
                width: 125,
                height: 125,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ACTION BUTTON
class ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D9CDB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                icon,
                height: 40,
                width: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 40,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                  height: 1.3,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
