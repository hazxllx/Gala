import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your Favorites screen here with alias to avoid conflict
import 'package:my_project/screens/favorites.dart' as fav;

// Import profile page with alias to avoid conflict
import 'package:my_project/screens/profile/profile_page.dart' as profile;
import 'package:my_project/screens/settings/settings.dart';

// Import notifications.dart with alias to avoid conflict
import 'package:my_project/screens/notifications.dart' as notif;

class CafePage extends StatefulWidget {
  final String locationName;

  const CafePage({super.key, required this.locationName});

  @override
  State<CafePage> createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;

  // Store favorite cafe titles for quick lookup
  Set<String> favoriteCafeTitles = {};

  // Define your cafes as data objects only
  final List<CafeData> allCafes = const [
    CafeData(
      imagePath: 'assets/arco_diez.jpeg',
      title: 'Arco Diez Cafe',
      subtitle: 'Pacol Rd, Naga',
      rating: 4.6,
    ),
    CafeData(
      imagePath: 'assets/tct.jpg',
      title: 'The Coffee Table',
      subtitle: 'Magsaysay Ave, Naga',
      rating: 4.3,
    ),
    CafeData(
      imagePath: 'assets/harina.jpeg',
      title: 'Harina Cafe',
      subtitle: 'Narra St, Naga',
      rating: 4.1,
    ),
  ];

  final List<CafeData> nearbyCafes = const [
    CafeData(
      imagePath: 'assets/beanleaf.png',
      title: 'Beanleaf Coffee and Tea',
      subtitle: '2F Grand Master Mall',
      rating: 4.4,
    ),
    CafeData(
      imagePath: 'assets/bellissimo.png',
      title: 'Bellissimo Boulangerie & Patisserie',
      subtitle: '800, 461',
      rating: 4.4,
    ),
    CafeData(
      imagePath: 'assets/garden_cafe.jpeg',
      title: 'Starmark Cafe',
      subtitle: 'Diaz St. cor Peñafrancia',
      rating: 4.2,
    ),
  ];

  bool get isNaga => widget.locationName.toLowerCase().contains('naga');
  bool get isSearching => _searchController.text.isNotEmpty;

  List<CafeData> get _filteredCafes {
    if (!isNaga) return [];
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];
    final allCafesList = [...allCafes, ...nearbyCafes];
    return allCafesList.where((cafe) {
      return cafe.title.toLowerCase().contains(query) ||
          cafe.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  User? user;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    user = FirebaseAuth.instance.currentUser ;
    userPhotoUrl = user?.photoURL;
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (user == null) return;
    final favSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .get();

    setState(() {
      favoriteCafeTitles =
          favSnapshot.docs.map((doc) => doc.id).toSet(); // Using doc id as cafe title
    });
  }

  Future<void> _toggleFavorite(CafeData cafe) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites')),
      );
      return;
    }
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(cafe.title);

    final isFav = favoriteCafeTitles.contains(cafe.title);

    if (isFav) {
      await favRef.delete();
      setState(() {
        favoriteCafeTitles.remove(cafe.title);
      });
    } else {
      await favRef.set({
        'imagePath': cafe.imagePath,
        'subtitle': cafe.subtitle,
        'rating': cafe.rating,
        'addedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        favoriteCafeTitles.add(cafe.title);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build CafeCard widget from CafeData
  Widget _buildCafeCard(CafeData cafe) {
    final isFavorite = favoriteCafeTitles.contains(cafe.title);
    return CafeCard(
      imagePath: cafe.imagePath,
      title: cafe.title,
      subtitle: cafe.subtitle,
      rating: cafe.rating,
      isFavorite: isFavorite,
      onFavoriteToggle: () => _toggleFavorite(cafe),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gala',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: userPhotoUrl != null
                            ? NetworkImage(userPhotoUrl!)
                            : const AssetImage('assets/user.png') as ImageProvider,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isNaga)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.08 * 255).round()),
                            blurRadius: 12,
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
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search cafes...',
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Cafes',
                            style: TextStyle(
                              color: Color.fromARGB(255, 11, 116, 177),
                              fontFamily: 'Inter',
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: ' in ${widget.locationName}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isSearching && isNaga) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D9CDB).withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 20,
                              color: Color(0xFF2D9CDB),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Search Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_filteredCafes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No cafes found',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: _filteredCafes.length,
                          itemBuilder: (context, index) {
                            final cafe = _filteredCafes[index];
                            return _buildCafeCard(cafe);
                          },
                        ),
                      ),
                  ],
                  if (!isSearching && isNaga) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha((0.1 * 255).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Top picks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withAlpha((0.3 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.sort, size: 16, color: Colors.blue),
                                SizedBox(width: 6),
                                Text(
                                  'Sort by',
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
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        children: allCafes.map(_buildCafeCard).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6), // reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha((0.1 * 255).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  size: 18, // smaller icon size
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8), // reduced spacing
                              Text(
                                'Nearby You',
                                style: TextStyle(
                                  fontSize: 18, // smaller font size
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // smaller padding
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withAlpha((0.3 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                                const SizedBox(width: 4), // reduced spacing
                                Text(
                                  widget.locationName,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12, // smaller font size
                                  ),
                                ),
                                const SizedBox(width: 6), // reduced spacing
                                const Text(
                                  'Change',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        children: nearbyCafes.map(_buildCafeCard).toList(),
                      ),
                    ),
                  ],
                  if (!isNaga)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.location_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No cafes available',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'for this location.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              bottom: 20,
            ),
            height: screenHeight * 0.08,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                    setState(() => selectedIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                _buildNavItem(
                  Icons.favorite_border,
                  Icons.favorite,
                  1,
                  isDark,
                  screenWidth,
                  () {
                    setState(() => selectedIndex = 1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => fav.FavoritesScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  Icons.notifications_none,
                  Icons.notifications,
                  2,
                  isDark,
                  screenWidth,
                  () {
                    setState(() => selectedIndex = 2);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const notif.NotificationsPage(),
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  Icons.person_outline,
                  Icons.person,
                  3,
                  isDark,
                  screenWidth,
                  () {
                    setState(() => selectedIndex = 3);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profile.ProfilePage(
                          username: user?.displayName ?? 'User   ',
                          onSettingsTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsPage()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
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
              ? Colors.blue.withOpacity(0.15)
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
}

class CafeData {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating;

  const CafeData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
  });
}

class CafeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const CafeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 190,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  height: 250,
                  width: 170,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 300,
                  width: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 12,
            right: 12,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 12,
            right: 50,
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey[600],
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}