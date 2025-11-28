import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/screens/home/cafe.dart' as naga;
import 'package:my_project/screens/home/pili_cafe/pili_cafe.dart' as pili;
import 'package:my_project/screens/home/naga_bars.dart' as bars;
import 'package:my_project/screens/home/pili_resorts.dart';
import 'package:my_project/screens/home/naga_parks.dart';
import 'package:my_project/screens/home/header.dart';

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
                builder: (context) => pili.CafePage(locationName: locationName),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => naga.CafePage(locationName: locationName),
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
                builder: (context) => bars.BarsPage(locationName: locationName),
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
            .where((cat) => cat['name'].toString().toLowerCase().contains(query))
            .toList();
      });
    });
  }

  void _sortCategories(String sortType) {
    setState(() {
      if (sortType == 'A-Z') {
        filteredCategories.sort((a, b) =>
            a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));
      } else if (sortType == 'Z-A') {
        filteredCategories.sort((a, b) =>
            b['name'].toString().toLowerCase().compareTo(a['name'].toString().toLowerCase()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(30),
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
                  Icon(Icons.search, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                        child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
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

            // CATEGORY SCROLL ROW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filteredCategories.map((category) {
                  final String name = category['name'] as String;

                  final Color accent = name == 'Cafes'
                      ? (isDarkMode ? const Color.fromARGB(255, 244, 194, 171)
                                    : const Color.fromARGB(255, 184, 101, 71))
                      : name == 'Bars'
                          ? (isDarkMode ? const Color.fromARGB(255, 149, 239, 167)
                                        : const Color.fromARGB(255, 31, 166, 35))
                          : name == 'Resorts'
                              ? (isDarkMode ? const Color.fromARGB(255, 162, 208, 255)
                                            : const Color(0xFF1A73E8))
                              : name == 'Parks'
                                  ? (isDarkMode ? const Color.fromARGB(255, 176, 231, 185)
                                                : const Color(0xFF2E7D32))
                                  : (isDarkMode ? const Color.fromARGB(255, 174, 151, 255)
                                                : const Color.fromARGB(255, 44, 13, 98));

                  return Row(
                    children: [
                      CategoryCard(
                        image: category['image'],
                        name: name,
                        onTap: () {
                          if (category.containsKey('onTap')) {
                            category['onTap'](context, widget.locationName);
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
            ActionButton(icon: 'assets/nearby.png', label: "Find nearby places", isDarkMode: isDarkMode),
            const SizedBox(height: 12),
            ActionButton(icon: 'assets/directions.png', label: "Get directions", isDarkMode: isDarkMode),
            const SizedBox(height: 12),
            ActionButton(icon: 'assets/fare.png', label: "Check public transport & fare", isDarkMode: isDarkMode),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


/// CATEGORY CARD WITH SCALE + HOVER GLOW ✨
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
    this.height = 173, // +3 size improvement
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  double scale = 1.0;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final glowColor = Colors.white.withOpacity(0.45); // SOFT WHITE GLOW (Choice A)

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => scale = 0.94),
        onTapCancel: () => setState(() => scale = 1.0),
        onTapUp: (_) {
          setState(() => scale = 1.0);
          Future.delayed(const Duration(milliseconds: 90), widget.onTap);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(scale),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
            border: Border.all(
              color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hovering ? glowColor : Colors.black.withOpacity(0.08),
                blurRadius: hovering ? 22 : 8,
                offset: hovering ? const Offset(0, 0) : const Offset(0, 4),
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
                  width: 128,  // +3 bigger
                  height: 128, // +3 bigger
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
                    fontSize: 16,
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
      ),
    );
  }
}


/// ACTION BUTTON — unchanged
class ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isDarkMode;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Image.asset(icon, height: 40, width: 40),
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
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
        ],
      ),
    );
  }
}

