/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-005] Homepage(Category)
Description:The Category allows users to explore and search 
through different location categories (like Cafes, Restaurants, etc.) for a specific location.
 */

// To display categories of locations for a specific place, allowing users to search, filter,
//and navigate to each category's page, enhancing the overall experience of exploring different places.

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
      {"image": 'assets/park.png', "name": "Parks"},
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 6),
            Text(
              "Gala",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(
                'assets/user.png',
              ), // unaffected by dark mode
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            // Search bar for filtering categories
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow:
                    isDarkMode
                        ? []
                        : [
                          BoxShadow(
                            color: const Color.fromARGB(26, 0, 0, 0),
                            blurRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: textColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: "Search here..",
                        hintStyle: TextStyle(color: textColor.withAlpha(150)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Where do you want to go?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.sort, color: Colors.blue),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Sort by",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                                    : category['name'] == 'Parks'
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

                          const SizedBox(width: 10),
                        ],
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "What do you want to do?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            // Action buttons
            ActionButton(
              icon: 'assets/nearby.png',
              label: "Find nearby places",
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 10),
            ActionButton(
              icon: 'assets/directions.png',
              label: "Get directions",
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 10),
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
    this.width = 140,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow:
              isDarkMode
                  ? []
                  : [
                    BoxShadow(
                      color: const Color.fromARGB(26, 0, 0, 0),
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 150, height: 120), // scale image height
            const SizedBox(height: 1),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        boxShadow:
            isDarkMode
                ? []
                : [
                  BoxShadow(
                    color: const Color.fromARGB(26, 0, 0, 0),
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Row(
        children: [
          Image.asset(icon, height: 40),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
