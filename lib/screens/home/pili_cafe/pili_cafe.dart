import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Cafe detail page import (adjust the path as needed)
import 'package:my_project/screens/favorites.dart' as fav;
import 'package:my_project/screens/profile/profile_page.dart' as profile;
import 'package:my_project/screens/settings/settings.dart';
import 'package:my_project/screens/notifications.dart' as notif;
import 'package:my_project/screens/home/header.dart';

class CafePage extends StatefulWidget {
  final String locationName;
  const CafePage({super.key, required this.locationName});

  @override
  State<CafePage> createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  final TextEditingController _searchController = TextEditingController();
  int selectedIndex = 0;

  // Top picks cafes for Pili - UPDATED TO USE CLOUD URLS
  List<CafeData> allCafes = [
    CafeData(
      imagePath: 'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_cafe/taste_some_coffee/tsc.jpg',
      title: 'Taste Some Coffee',
      subtitle: 'PMJ Building Room 2 Imperial Street San Isidro, Pili',
    ),
    CafeData(
      imagePath: 'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/pili_cafe/beannie/beannie1.jpg',
      title: 'Beannie Cafe',
      subtitle: 'Diversion Crossing La Purisima, Pili',
    ),
  ];

  bool get isPili => widget.locationName.toLowerCase().contains('pili');
  bool get isSearching => _searchController.text.isNotEmpty;

  List<CafeData> get _filteredCafes {
    if (!isPili) return [];
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];
    return allCafes.where((cafe) {
      return cafe.title.toLowerCase().contains(query) ||
          cafe.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  User? user;
  String? userPhotoUrl;
  Stream<Set<String>> favoriteCafeTitlesStream = Stream.value(<String>{});

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    user = FirebaseAuth.instance.currentUser;
    userPhotoUrl = user?.photoURL;
    if (user != null) {
      favoriteCafeTitlesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('favorites')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
    }
  }

  // Add sorting methods
  void _sortCafes(String sortType, List<CafeData> cafesToSort) {
    setState(() {
      if (sortType == 'A-Z') {
        cafesToSort.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      } else if (sortType == 'Z-A') {
        cafesToSort.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
      }
    });
  }

  void _sortAllCafes(String sortType) {
    _sortCafes(sortType, allCafes);
  }

  Future<void> _toggleFavorite(CafeData cafe, Set<String> favoriteCafeTitles) async {
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
    } else {
      await favRef.set({
        'imagePath': cafe.imagePath,
        'subtitle': cafe.subtitle,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Widget _buildCafeCard(CafeData cafe, Set<String> favoriteCafeTitles) {
    final isFavorite = favoriteCafeTitles.contains(cafe.title);

    return GestureDetector(
      onTap: () {
        // Add navigation logic for specific cafes if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No details page yet for ${cafe.title}')),
        );
      },
      child: CafeCard(
        imagePath: cafe.imagePath,
        title: cafe.title,
        subtitle: cafe.subtitle,
        isFavorite: isFavorite,
        onFavoriteToggle: () => _toggleFavorite(cafe, favoriteCafeTitles),
        user: user,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: GalaHeader(
        userPhotoUrl: userPhotoUrl,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPili)
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
                            style: TextStyle(
                              fontSize: 32,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (isSearching && isPili) ...[
                    StreamBuilder<Set<String>>(
                      stream: favoriteCafeTitlesStream,
                      builder: (context, snapshot) {
                        final favoriteCafeTitles = snapshot.data ?? <String>{};
                        if (_filteredCafes.isEmpty) {
                          return Center(
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
                          );
                        } else {
                          return SizedBox(
                            height: 190,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: _filteredCafes.length,
                              itemBuilder: (context, index) {
                                final cafe = _filteredCafes[index];
                                return _buildCafeCard(cafe, favoriteCafeTitles);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                  if (!isSearching && isPili) ...[
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
                                  color: Colors.orange.withAlpha((0.13 * 255).round()),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.star,
                                  size: 20,
                                  color: isDark ? Colors.yellow[400] : Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Top picks',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                          // Functional PopupMenuButton for sorting
                          PopupMenuButton<String>(
                            onSelected: _sortAllCafes,
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
                                color: Colors.blue.withAlpha((0.1 * 255).round()),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.blue.withAlpha((0.3 * 255).round()),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<Set<String>>(
                      stream: favoriteCafeTitlesStream,
                      builder: (context, snapshot) {
                        final favoriteCafeTitles = snapshot.data ?? <String>{};
                        return SizedBox(
                          height: 190,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            children: allCafes.map((cafe) => _buildCafeCard(cafe, favoriteCafeTitles)).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                  if (!isPili)
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
                          username: user?.displayName ?? 'User',
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

  const CafeData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class CafeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final User? user;

  const CafeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.user,
  });

  Stream<({double? average, int count, int? userRating})> getRatingInfo() {
    final ratingsRef = FirebaseFirestore.instance
        .collection('cafes')
        .doc(title)
        .collection('ratings');
    return ratingsRef.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        return (average: null, count: 0, userRating: null);
      }
      final ratings = docs.map((doc) => (doc.data()['rating'] ?? 0).toDouble()).toList();
      double avg = ratings.reduce((a, b) => a + b) / ratings.length;
      int? myRating;
      if (user != null) {
        final myDoc = docs.where((d) => d.id == user!.uid).toList();
        if (myDoc.isNotEmpty) {
          myRating = myDoc.first['rating'];
        }
      }
      return (average: avg, count: docs.length, userRating: myRating);
    });
  }

  void _showRatingDialog(BuildContext context, {int? yourRating}) {
    int selectedRating = yourRating ?? 0;
    bool hasRated = yourRating != null;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isEnabled = selectedRating != 0 && selectedRating != yourRating && !isSubmitting;
            return Dialog(
              backgroundColor: const Color(0xFFF8F8FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rate $title',
                      style: const TextStyle(
                        color: Color(0xFF0B55A0),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: i < selectedRating
                                ? const Color(0xFF0B55A0)
                                : Colors.amber,
                            size: 36,
                          ),
                          splashRadius: 24,
                          onPressed: () => setDialogState(() {
                            selectedRating = i + 1;
                          }),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF0B55A0),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isEnabled
                                ? () async {
                                    setDialogState(() => isSubmitting = true);
                                    if (user != null) {
                                      final ratingRef = FirebaseFirestore.instance
                                          .collection('cafes')
                                          .doc(title)
                                          .collection('ratings')
                                          .doc(user!.uid);
                                      await ratingRef.set({'rating': selectedRating});
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Thanks for rating $title!'),
                                          backgroundColor: const Color(0xFF0B55A0),
                                        ),
                                      );
                                    }
                                    setDialogState(() => isSubmitting = false);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnabled
                                  ? const Color(0xFF0B55A0)
                                  : Colors.grey[300],
                              foregroundColor: isEnabled
                                  ? Colors.white
                                  : Colors.grey,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    if (hasRated)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (user != null) {
                                    final ratingRef = FirebaseFirestore.instance
                                        .collection('cafes')
                                        .doc(title)
                                        .collection('ratings')
                                        .doc(user!.uid);
                                    await ratingRef.delete();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Your rating was removed!'),
                                        backgroundColor: Colors.grey[600],
                                      ),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          label: const Text(
                            "Remove my rating",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 170,
      height: 190,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Colors.white.withOpacity(0.09) : Colors.grey[200],
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
                Image.network(
                  imagePath,
                  height: 250,
                  width: 170,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      width: 170,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      width: 170,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    );
                  },
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
          // Rating
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () async {
                getRatingInfo().first.then((info) {
                  _showRatingDialog(context, yourRating: info.userRating);
                });
              },
              child: StreamBuilder<({double? average, int count, int? userRating})>(
                stream: getRatingInfo(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  final showAverage = (info?.average != null && info!.count > 0);
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.13),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          showAverage
                              ? '${info.average!.toStringAsFixed(1)} Ratings'
                              : 'Ratings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.black : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
