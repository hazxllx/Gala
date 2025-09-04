import 'package:flutter/material.dart';
import 'package:my_project/screens/home/cafe.dart';

/// CategoryScreen displays a list of categories for a specific location.
/// It allows users to search and navigate to different categories like Cafes, Restaurants, etc.
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

  @override
  void initState() {
    super.initState();

    // List of all categories available
    allCategories.addAll([
      {
        "image": 'assets/cafe.png',
        "name": "Cafes",
        "onTap": (BuildContext context, String locationName) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CafePage(locationName: locationName),
            ),
          );
        },
      },
      {"image": 'assets/ffchains.png', "name": "Fast Food Chains"},
      {"image": 'assets/restaurant.png', "name": "Restaurants"},
      {"image": 'assets/inuman.png', "name": "Bars"},
    ]);

    filteredCategories = allCategories;

    // Listen to the search input and filter categories based on it
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        filteredCategories =
            allCategories
                .where(
                  (cat) => cat['name'].toString().toLowerCase().contains(query),
                )
                .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final bgColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FB);
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // Increased height for better spacing
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Better padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button with improved styling
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: textColor,
                      ),
                    ),
                  ),
                  
                  // Logo and Gala text with better spacing
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/logo.png', 
                          height: 32,
                          width: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Gala",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  // Profile picture with enhanced styling
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: const AssetImage('assets/user.png'),
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 20), // Increased spacing
            // Search bar for filtering categories with improved styling
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
                  Icon(
                    Icons.search, 
                    color: Colors.grey[500],
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search categories...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32), // Better spacing
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
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
              ],
            ),
            const SizedBox(height: 16),
            // Categories listed horizontally
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    filteredCategories.map((category) {
                      return Row(
                        children: [
                          CategoryCard(
                            image: category['image'],
                            name: category['name'],
                            onTap: () {
                              if (category.containsKey('onTap')) {
                                category['onTap'](context, widget.locationName);
                              }
                            },
                            isDarkMode: isDarkMode,
                            textColor:
                                category['name'] == 'Cafes'
                                    ? (isDarkMode
                                        ? Color.fromARGB(255, 244, 194, 171)
                                        : Color.fromARGB(255, 184, 101, 71))
                                    : category['name'] == 'Bars'
                                    ? (isDarkMode
                                        ? Color.fromARGB(255, 149, 239, 167)
                                        : Color.fromARGB(255, 31, 166, 35))
                                    : category['name'] == 'Fast Food Chains'
                                    ? (isDarkMode
                                        ? Color.fromARGB(255, 255, 125, 118)
                                        : Color.fromARGB(255, 211, 41, 28))
                                    : (isDarkMode
                                        ? Color.fromARGB(255, 174, 151, 255)
                                        : Color.fromARGB(255, 44, 13, 98)),
                            // Default for "Restaurants"
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
            // Action buttons with improved styling
            ActionButton(
              icon: 'assets/nearby.png',
              label: "Find nearby places",
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            ActionButton(
              icon: 'assets/directions.png',
              label: "Get directions",
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            ActionButton(
              icon: 'assets/fare.png',
              label: "Check public transport & fare",
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// CategoryCard displays a category with an image and name.
/// When tapped, it triggers the provided `onTap` function.
class CategoryCard extends StatelessWidget {
  final String image;
  final String name;
  final VoidCallback onTap;
  final bool isDarkMode;

  // Optional parameters to control size with defaults
  final double width;
  final double height;

  final Color textColor; // NEW

  const CategoryCard({
    super.key,
    required this.image,
    required this.name,
    required this.onTap,
    required this.isDarkMode,
    required this.textColor, // NEW
    this.width = 155, // Increased from 145 to accommodate larger images
    this.height = 170, // Increased from 155 to accommodate larger images
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                image, 
                width: 125, // Increased from 100 to 110 (+10)
                height: 125, // Increased from 100 to 110 (+10)
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
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

/// ActionButton displays an action item with an icon and label.
/// It represents actions like finding nearby places or getting directions.
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
                        child: Image.asset(
              icon, 
              height: 40, // Increased from 32 to 37 (+5)
              width: 40, // Increased from 32 to 37 (+5)
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
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[500],
          ),
        ],
      ),
    );
  }
}