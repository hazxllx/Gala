import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sidebar.dart';
import 'category.dart';
import 'package:provider/provider.dart';
import 'package:my_project/theme/theme_notifier.dart';

// Import your screens
import 'package:my_project/screens/favorites.dart' as fav;
import 'package:my_project/screens/profile/profile_page.dart' as profile;
import 'package:my_project/screens/settings/settings.dart';
import 'package:my_project/screens/notifications.dart' as notif;

class HomePage extends StatefulWidget {
  final String? username;

  const HomePage({super.key, this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool showAll = false;
  String searchQuery = "";
  int selectedIndex = 0;
  String? username;
  String? userPhotoUrl;

  bool _isAvatarPressed = false; // smooth scale animation flag

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          username = doc.data()?['username'] as String? ?? 'User';
          userPhotoUrl = user.photoURL;
        });
      }
    } catch (e) {
      setState(() {
        username = 'User';
        userPhotoUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final displayedLocations = locations
        .where(
          (location) => location['name']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: Sidebar(onLogout: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: screenWidth * 0.45,
        leading: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.iconTheme.color),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

            Image.asset(
              isDark ? 'assets/logo_white.png' : 'assets/logo.png',
              height: isDark ? screenHeight * 0.05 : screenHeight * 0.035,
              width: isDark ? screenHeight * 0.05 : null,
              fit: BoxFit.contain,
            ),

            SizedBox(width: screenWidth * 0.015),

            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.37, 1.0],
                  colors: isDark
                      ? [Color(0xFF58BCF1), Color(0xFFFFFFFF)]
                      : [Color(0xFF041D66), Color(0xFF000000)],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
              },
              child: Text(
                "Gala",
                style: TextStyle(
                  fontFamily: 'Sarina',
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: theme.iconTheme.color,
              size: screenWidth * 0.06,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
          SizedBox(width: screenWidth * 0.04),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: screenWidth * 0.045,
              right: screenWidth * 0.045,
              bottom: screenHeight * 0.18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Mabuhay, ${username ?? '...'}!",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: screenWidth * 0.055,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ▪▪▪ Avatar clickable + smooth scale animation ▪▪▪
                    GestureDetector(
                      onTapDown: (_) => setState(() => _isAvatarPressed = true),
                      onTapUp: (_) {
                        setState(() => _isAvatarPressed = false);
                        Future.delayed(Duration(milliseconds: 120), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => profile.ProfilePage(
                                username: username ?? 'User',
                                onSettingsTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        });
                      },
                      onTapCancel: () =>
                          setState(() => _isAvatarPressed = false),

                      child: AnimatedScale(
                        scale: _isAvatarPressed ? 0.88 : 1.0,
                        duration: Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: CircleAvatar(
                          backgroundImage: userPhotoUrl != null
                              ? NetworkImage(userPhotoUrl!)
                              : AssetImage('assets/user.png')
                                  as ImageProvider,
                          backgroundColor: Colors.transparent,
                          radius: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discover places in ",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Camarines Sur!",
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        color: isDark
                            ? Colors.blue[200]!
                            : Color.fromARGB(255, 13, 94, 161),
                        fontWeight: FontWeight.bold,
                        height: 0.7,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search for a location",
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.iconTheme.color,
                      size: screenWidth * 0.06,
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04,
                    ),
                  ),
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),

                SizedBox(height: screenHeight * 0.02),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Search for a Location",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: screenWidth * 0.045,
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
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                if (displayedLocations.isEmpty)
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                      child: Text(
                        "No locations found.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ),

                if (displayedLocations.isNotEmpty)
                  searchQuery.isNotEmpty || showAll
                      ? Wrap(
                          spacing: screenWidth * 0.02,
                          runSpacing: screenWidth * 0.02,
                          children: displayedLocations.map((location) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryScreen(
                                      locationName: location['name']!,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width:
                                    (screenWidth - (screenWidth * 0.09) - screenWidth * 0.02) /
                                        2,
                                child: LocationCard(
                                  location: location,
                                  height: screenHeight * 0.18 * 1.03, // +3%
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : SizedBox(
                          height: screenHeight * 0.32 * 1.03, // +3%
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (displayedLocations.length / 2).ceil(),
                            itemBuilder: (context, columnIndex) {
                              final firstIndex = columnIndex * 2;
                              final secondIndex = firstIndex + 1;

                              return Padding(
                                padding:
                                    EdgeInsets.only(right: screenWidth * 0.03),
                                child: Column(
                                  children: [
                                    _buildLocationTile(
                                      context,
                                      displayedLocations[firstIndex],
                                      screenWidth,
                                      screenHeight,
                                    ),
                                    SizedBox(height: screenHeight * 0.018),
                                    if (secondIndex < displayedLocations.length)
                                      _buildLocationTile(
                                        context,
                                        displayedLocations[secondIndex],
                                        screenWidth,
                                        screenHeight,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                SizedBox(height: screenHeight * 0.07),

                Center(
                  child: Container(
                    width: screenWidth * 1.2,
                    height: screenHeight * 0.25,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Color.fromARGB(255, 1, 26, 55)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Beyond Just Locations,",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Discover Camarines Sur's Best!",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.blue[200]!
                                : Color.fromARGB(255, 14, 94, 159),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Explore Camarines Sur like never before! From breathtaking tourist spots to top-rated hotels, we bring you the best places to visit, stay, and experience.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // bottom nav
          Positioned(
            bottom: screenHeight * 0.06,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Container(
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.home_outlined,
                    Icons.home,
                    0,
                    isDark,
                    screenWidth,
                    () {
                      if (selectedIndex != 0) {
                        setState(() => selectedIndex = 0);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePage(username: username),
                          ),
                        );
                      }
                    },
                  ),
                  _buildNavItem(
                    Icons.favorite_border,
                    Icons.favorite,
                    1,
                    isDark,
                    screenWidth,
                    () {
                      if (selectedIndex != 1) {
                        setState(() => selectedIndex = 1);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => fav.FavoritesScreen()),
                        );
                      }
                    },
                  ),
                  _buildNavItem(
                    Icons.notifications_none,
                    Icons.notifications,
                    2,
                    isDark,
                    screenWidth,
                    () {
                      if (selectedIndex != 2) {
                        setState(() => selectedIndex = 2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                notif.NotificationsPage(username: username),
                          ),
                        );
                      }
                    },
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    3,
                    isDark,
                    screenWidth,
                    () {
                      if (selectedIndex != 3) {
                        setState(() => selectedIndex = 3);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => profile.ProfilePage(
                              username: username ?? 'User',
                              onSettingsTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData inactiveIcon,
    IconData activeIcon,
    int index,
    bool isDark,
    double screenWidth,
    VoidCallback onTap,
  ) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.025,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            key: ValueKey(isSelected),
            size: screenWidth * 0.065,
            color: isSelected
                ? Colors.blue
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    Map<String, String> location,
    double screenWidth,
    double screenHeight,
  ) {
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
        width: (screenWidth -
                (screenWidth * 0.09) -
                screenWidth * 0.06) /
            2.2,
        height: screenHeight * 0.15 * 1.03, // +3%
        child: LocationCard(
          location: location,
          height: screenHeight * 0.15 * 1.03,
          width: (screenWidth -
                  (screenWidth * 0.09) -
                  screenWidth * 0.06) /
              2.2,
        ),
      ),
    );
  }
}

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.99,
                child: Image.asset(
                  location['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: screenWidth * 0.03,
              bottom: screenWidth * 0.03,
              right: screenWidth * 0.03,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenWidth * 0.01,
                ),
                child: Text(
                  location['name']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.045,
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

final List<Map<String, String>> locations = [
  {'name': 'Naga City', 'image': 'assets/naga_city.png'},
  {'name': 'Pili', 'image': 'assets/pili.jpg'},
  {'name': 'Siruma', 'image': 'assets/siruma.jpg'},
  {'name': 'Caramoan', 'image': 'assets/caramoan.png'},
  {'name': 'Pasacao', 'image': 'assets/pasacao.png'},
  {'name': 'Tinambac', 'image': 'assets/tinambac.jpg'},
];
