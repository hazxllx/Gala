/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-005] Homepage
Description: Homepage displays the main UI for discovering Camarines Sur locations.
 */

//This code creates a home page that shows a list of places in Camarines Sur with a search feature. 
//It has a top bar, a floating search button, a bottom menu, and clickable location cards. 
//The LocationCard widget displays each place's image and name, and users can search or view more details.

import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAll = false;
  bool showSearchBar = false;
  String searchQuery = "";
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter locations based on search query
    final displayedLocations = locations
        .where((location) => location['name']!
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Sidebar(onLogout: () {}),

      /// App bar with logo and menu icon
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 180,
        leading: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.iconTheme.color),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 6),
            Text(
              "Gala",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [SizedBox(width: 16)],
      ),

      /// Main body content
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Greeting with avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mabuhay, User!",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor: Colors.transparent,
                  radius: 20,
                ),
              ],
            ),
            const SizedBox(height: 11),

            /// Header: Discover Camarines Sur
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover places in ",
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 33),
                ),
                Text(
                  "Camarines Sur!",
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    height: 0.7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),

            /// Search bar toggle
            if (showSearchBar)
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search for a location",
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 18),
              ),

            const SizedBox(height: 16),

            /// Search label + toggle button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Search for a Location",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (searchQuery.isEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showAll = !showAll;
                      });
                    },
                    child: Text(
                      showAll ? "Show Less" : "View All",
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
              ],
            ),

            /// No results fallback
            if (displayedLocations.isEmpty)
              Center(
                child: Text(
                  "No locations found.",
                  style:
                      TextStyle(fontSize: 16, color: theme.colorScheme.error),
                ),
              ),

            /// Display search results or carousel
            if (displayedLocations.isNotEmpty)
              searchQuery.isNotEmpty || showAll
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: displayedLocations.map((location) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryScreen(
                                    locationName: location['name']!),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 48) / 2,
                            child: LocationCard(location: location),
                          ),
                        );
                      }).toList(),
                    )
                  : SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (displayedLocations.length / 2).ceil(),
                        itemBuilder: (context, columnIndex) {
                          final firstIndex = columnIndex * 2;
                          final secondIndex = firstIndex + 1;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                _buildLocationTile(
                                    context, displayedLocations[firstIndex]),
                                const SizedBox(height: 12),
                                if (secondIndex < displayedLocations.length)
                                  _buildLocationTile(
                                      context, displayedLocations[secondIndex]),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

            const SizedBox(height: 16),

            /// Informational box at the bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Beyond Just Locations,",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Discover Camarines Sur’s Best!",
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Explore Camarines Sur like never before! From breathtaking tourist spots to top-rated hotels, we bring you the best places to visit, stay, and experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// Floating search button
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            showSearchBar = !showSearchBar;
            if (!showSearchBar) searchQuery = "";
          });
        },
        child: Icon(
          showSearchBar ? Icons.close : Icons.search,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom navigation bar with 4 icons
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorites"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Alerts"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }

  /// Builds a vertical location tile used in horizontal scrolling list
  Widget _buildLocationTile(
      BuildContext context, Map<String, String> location) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CategoryScreen(locationName: location['name']!),
          ),
        );
      },
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 64) / 2.2,
        height: 120,
        child: LocationCard(location: location),
      ),
    );
  }
}

/// A card widget that displays a location image and name overlay.
/// 
/// It is used inside the location list and offers a clickable card
/// for users to navigate to detailed location pages.
class LocationCard extends StatelessWidget {
  final Map<String, String> location;

  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.asset(
              location['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              color: Colors.black.withAlpha(80),
              alignment: Alignment.center,
              child: Text(
                location['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static list of locations in Camarines Sur with name and image.
final List<Map<String, String>> locations = [
  {'name': 'Naga City', 'image': 'assets/naga_city.png'},
  {'name': 'Pili', 'image': 'assets/pili.jpg'},
  {'name': 'Siruma', 'image': 'assets/siruma.jpg'},
  {'name': 'Caramoan', 'image': 'assets/caramoan.png'},
  {'name': 'Pasacao', 'image': 'assets/pasacao.png'},
  {'name': 'Tinambac', 'image': 'assets/tinambac.jpg'},
];
