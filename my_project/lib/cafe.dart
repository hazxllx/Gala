/* Authored by: Hazel Salvador
Company: Eleutheria Ventures
Project: Gala
Feature: [GAL-005] Homepage(Cafe)
Description:The CafePage displays a list of cafes in a specific location, 
allowing users to search, explore, and view details about each cafe.
 */

// The purpose of this is to allow users to search, explore, and view
// details of cafes in a specific location, providing a seamless way to find and learn more about nearby cafes.
import 'package:flutter/material.dart';

// This is the main page that shows cafes in a specific location
class CafePage extends StatefulWidget {
  // The location name passed to the page (e.g. "Naga")
  final String locationName;

  const CafePage({super.key, required this.locationName});

  @override
  State<CafePage> createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  // This controller is used to manage the search bar input
  final TextEditingController _searchController = TextEditingController();

  // List of all cafes with details like image, title, and rating
  final List<CafeCard> allCafes = const [
    CafeCard(
      imagePath: 'assets/arco_diez.jpeg',
      title: 'Arco Diez Cafe',
      subtitle: 'Pacol Rd, Naga',
      rating: 4.6,
    ),
    CafeCard(
      imagePath: 'assets/royaltea.png',
      title: 'The Coffee Table',
      subtitle: 'Magsaysay Ave, Naga',
      rating: 4.3,
    ),
    CafeCard(
      imagePath: 'assets/kape_sina_una.jpeg',
      title: 'Harina Cafe',
      subtitle: 'Narra St, Naga',
      rating: 4.1,
    ),
  ];

  // This checks if the location is 'Naga'
  bool get isNaga => widget.locationName.toLowerCase().contains('naga');

  // This filters the cafes based on what the user types in the search bar
  List<CafeCard> get _filteredCafes {
    if (!isNaga) return [];  // If the location isn't 'Naga', show no cafes
    final query = _searchController.text.toLowerCase();  // Get the search text
    if (query.isEmpty) return allCafes;  // If there's no search text, show all cafes
    // Show cafes that match the search text in the title or subtitle
    return allCafes.where((cafe) {
      return cafe.title.toLowerCase().contains(query) ||
          cafe.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  // This method is called when the page is created
  @override
  void initState() {
    super.initState();
    // When the search text changes, update the page
    _searchController.addListener(() => setState(() {}));
  }

  // This method is called when the page is destroyed
  @override
  void dispose() {
    _searchController.dispose();  // Clean up the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the app is in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // Height of the AppBar
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button to go back to the previous page
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                ),
                // App logo and name
                Row(
                  children: [
                    Image.asset('assets/logo.png', height: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Gala',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                // User's profile picture
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/user.png'),
                  backgroundColor: Colors.transparent, // No tint in dark mode
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the search bar only if the location is 'Naga'
            if (isNaga)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,  // Controller for the search bar
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        decoration: const InputDecoration(
                          hintText: 'Search here..',  // Placeholder text in the search bar
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: Color(0xFF2D9CDB)),  // Search icon
                  ],
                ),
              ),

            // Display the title with the location name
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                children: [
                  const TextSpan(
                    text: 'Cafes',
                    style: TextStyle(color: Color(0xFF2D9CDB)),
                  ),
                  TextSpan(text: ' in ${widget.locationName}'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Show the cafes only if the location is 'Naga'
            if (isNaga) ...[
              // Section for top picked cafes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top picks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.sort, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'Sort by',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,  // Height of the horizontal list of cafes
                child: _filteredCafes.isEmpty
                    ? Center(
                        child: Text(
                          'No cafes found.',  // Message if no cafes match the search
                          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      )
                    : ListView(
                        scrollDirection: Axis.horizontal,  // Scroll horizontally
                        children: _filteredCafes,
                      ),
              ),
              const SizedBox(height: 24),

              // Section for cafes nearby the user
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby You',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.locationName,  // Display the current location
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Change location',
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,  // Height of the list of nearby cafes
                child: ListView(
                  scrollDirection: Axis.horizontal,  // Scroll horizontally
                  children: const [
                    CafeCard(
                      imagePath: 'assets/beanleaf.png',
                      title: 'Beanleaf Coffee and Tea',
                      subtitle: '2F Grand Master Mall',
                      rating: 4.4,
                    ),
                    CafeCard(
                      imagePath: 'assets/bellissimo.png',
                      title: 'Bellissimo Boulangerie & Patisserie',
                      subtitle: '800, 461',
                      rating: 4.4,
                    ),
                    CafeCard(
                      imagePath: 'assets/garden_cafe.jpeg',
                      title: 'Starmark Cafe',
                      subtitle: 'Diaz St. cor Peñafrancia',
                      rating: 4.2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],

            // If location is not 'Naga', show this message
            if (!isNaga)
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    'No cafes available for this location.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},  // Action when the search button is pressed
        backgroundColor: const Color(0xFF2D9CDB),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.search, color: Colors.white),  // Search icon on the button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navigation bar for navigating between pages
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: 0, // Set the currently selected tab index
          onTap: (index) {
            // Handle tab selection here
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
}

// This widget displays each cafe in a card format
class CafeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating;

  const CafeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              height: double.infinity,
              width: 160,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.orange),
                  const SizedBox(width: 2),
                  Text(
                    rating.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 8,
            right: 8,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            bottom: 18,
            left: 8,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            right: 8,
            child: Icon(Icons.favorite_border, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
