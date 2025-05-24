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
import 'package:provider/provider.dart';
import 'package:my_project/theme/theme_notifier.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

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
    final displayedLocations =
        locations
            .where(
              (location) => location['name']!.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Sidebar(onLogout: () {}),

      /// App bar with logo, menu icon, and dark mode toggle button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 180,
        leading: Row(
          children: [
            Builder(
              builder:
                  (context) => IconButton(
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
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),

        /// Added dark mode toggle icon button
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: theme.iconTheme.color,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      /// Main body content
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Greeting with avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mabuhay, ${widget.username}!",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor: Colors.transparent,
                  radius: 20,
                ),
              ],
            ),
            const SizedBox(height: 30),

            /// Header: Discover Camarines Sur
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Discover places in ",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "Camarines Sur!",
                  style: TextStyle(
                    fontSize: 30,
                    color:
                        isDark
                            ? Colors.blue[200]!
                            : const Color.fromARGB(255, 13, 94, 161),
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
                    color: isDark ? Colors.white : Colors.black,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),

            /// Display search results or carousel
            if (displayedLocations.isNotEmpty)
              searchQuery.isNotEmpty || showAll
                  ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        displayedLocations.map((location) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CategoryScreen(
                                        locationName: location['name']!,
                                      ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width:
                                  (MediaQuery.of(context).size.width - 48) / 2,
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
                                context,
                                displayedLocations[firstIndex],
                              ),
                              const SizedBox(height: 12),
                              if (secondIndex < displayedLocations.length)
                                _buildLocationTile(
                                  context,
                                  displayedLocations[secondIndex],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 40),

            /// Informational box at the bottom
            /// Informational box at the bottom
            /// Informational box at the bottom
            Center(
              child: Container(
                width: 360,
                height: 200, // Container size
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color.fromARGB(255, 1, 26, 55)
                          : Colors.white,

                  borderRadius: BorderRadius.circular(16), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ], // Optional shadow for depth
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Beyond Just Locations,",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Discover Camarines Sur’s Best!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark
                                ? Colors.blue[200]!
                                : const Color.fromARGB(255, 14, 94, 159),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Explore Camarines Sur like never before! From breathtaking tourist spots to top-rated hotels, we bring you the best places to visit, stay, and experience.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color:
                            isDark
                                ? Colors.white70
                                : const Color.fromARGB(226, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// Floating search button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 5,
        ), // lowers the FAB by 20 pixels
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color.fromARGB(255, 15, 114, 196),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ), // reduced vertical margin to 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
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
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: "Alerts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a vertical location tile used in horizontal scrolling list
  Widget _buildLocationTile(
    BuildContext context,
    Map<String, String> location,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CategoryScreen(locationName: location['name']!),
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
  final double height;
  final double width;

  const LocationCard({
    super.key,
    required this.location,
    this.height = 150,
    this.width = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.99,
                child: AspectRatio(
                  aspectRatio: 4 / 3, // Fix aspect ratio to 4:3
                  child: Image.asset(location['image']!, fit: BoxFit.cover),
                ),
              ),
            ),

            // Text overlay positioned at bottom-left
            Positioned(
              left: 12,
              bottom: 12,
              right: 12, // Optional, so text doesn't overflow
              child: Container(
                // Semi-transparent background for readability
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                child: Text(
                  location['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Bigger font size
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
