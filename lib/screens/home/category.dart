import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_project/screens/home/cafe.dart' as naga;
import 'package:my_project/screens/home/pili_cafe/pili_cafe.dart' as pili;
import 'package:my_project/screens/home/naga_bars.dart' as bars;
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
          // Check if location is Pili
          if (locationName.toLowerCase().contains('pili')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => pili.CafePage(locationName: locationName),
              ),
            );
          } else {
            // For other locations (like Naga), use the original CafePage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => naga.CafePage(locationName: locationName),
              ),
            );
          }
        },
      },
      {"image": 'assets/ffchains.png', "name": "Fast Food Chains"},
      {"image": 'assets/restaurant.png', "name": "Restaurants"},
      {
        "image": 'assets/inuman.png',
        "name": "Bars",
        "onTap": (BuildContext context, String locationName) {
          // Navigate to bars page (currently only Naga has bars)
          if (locationName.toLowerCase().contains('naga')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => bars.BarsPage(locationName: locationName),
              ),
            );
          } else {
            // Show message if no bars available for other locations
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
    filteredCategories = allCategories;

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
      appBar: GalaHeader(
        userPhotoUrl: user?.photoURL,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 20),
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
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'A-Z',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha, size: 16),
                          SizedBox(width: 8),
                          Text('Sort A–Z'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
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
                        textColor: category['name'] == 'Cafes'
                            ? (isDarkMode
                                ? const Color.fromARGB(255, 244, 194, 171)
                                : const Color.fromARGB(255, 184, 101, 71))
                            : category['name'] == 'Bars'
                                ? (isDarkMode
                                    ? const Color.fromARGB(255, 149, 239, 167)
                                    : const Color.fromARGB(255, 31, 166, 35))
                                : category['name'] == 'Fast Food Chains'
                                    ? (isDarkMode
                                        ? const Color.fromARGB(255, 255, 125, 118)
                                        : const Color.fromARGB(255, 211, 41, 28))
                                    : (isDarkMode
                                        ? const Color.fromARGB(255, 174, 151, 255)
                                        : const Color.fromARGB(255, 44, 13, 98)),
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

class CategoryCard extends StatelessWidget {
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
    this.height = 170,
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
                width: 125,
                height: 125,
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
              height: 40,
              width: 40,
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
