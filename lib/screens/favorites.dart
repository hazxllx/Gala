import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:my_project/screens/home/arcodiez/arco_diez.dart';
import 'package:my_project/screens/home/harina/harina.dart';


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}


class _CategoryData {
  final String label;
  final IconData icon;
  const _CategoryData(this.label, this.icon);
}


class _FavoritesScreenState extends State<FavoritesScreen> {
  User? user;
  late final CollectionReference favoritesRef;
  final List<_CategoryData> categories = const [
    _CategoryData('Cafes', Icons.local_cafe),
    _CategoryData('Parks', Icons.park),
    _CategoryData('Resorts', Icons.villa),
    _CategoryData('Restaurants', Icons.restaurant),
    _CategoryData('Bars', Icons.local_bar),
  ];
  int selectedCategoryIndex = 0;


  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('favorites');
    }
  }


  String _extractCityName(String subtitle) {
    final cities = ['Naga City', 'Pili', 'Siruma', 'Caramoan', 'Pasacao', 'Tinambac'];
    
    for (var city in cities) {
      if (subtitle.toLowerCase().contains(city.toLowerCase())) {
        return city;
      }
    }
    
    return 'Unknown City';
  }


  Map<String, List<Map<String, dynamic>>> _groupByCity(List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var item in items) {
      final city = _extractCityName(item['subtitle'] as String);
      if (!grouped.containsKey(city)) {
        grouped[city] = [];
      }
      grouped[city]!.add(item);
    }
    
    return grouped;
  }


  void _navigateToDetail(BuildContext context, String cafeTitle) {
    if (cafeTitle == 'Arco Diez Cafe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ArcoDiezPage()),
      );
    } else if (cafeTitle == 'Harina Cafe') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HarinaCafePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No details page yet for $cafeTitle')),
      );
    }
  }


  Future<String> _getEstablishmentType(String establishmentName) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('cafes')
          .doc(establishmentName)
          .get();
      
      if (doc.exists) {
        final type = doc.data()?['type'] as String?;
        return type ?? 'Cafe';
      }
    } catch (e) {
      debugPrint('Error fetching type: $e');
    }
    return 'Cafe';
  }


  String _normalizeType(String type) {
    final normalized = type.toLowerCase().trim();
    if (normalized == 'bar') return 'Bar';
    if (normalized == 'cafe' || normalized == 'café') return 'Cafe';
    if (normalized == 'restaurant') return 'Restaurant';
    if (normalized == 'park' || normalized.contains('park')) return 'Park';
    if (normalized == 'resort' || normalized.contains('resort')) return 'Resort';
    return type;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const Center(child: Text('Please log in to view favorites')),
      );
    }


    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xffF8F9FB),
      appBar: AppBar(
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Favorites',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: user!.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('assets/user.png') as ImageProvider,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Row(
              children: List.generate(categories.length, (i) {
                final selected = selectedCategoryIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _CategoryPill(
                    icon: categories[i].icon,
                    label: categories[i].label,
                    selected: selected,
                    onTap: () => setState(() => selectedCategoryIndex = i),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: favoritesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.grey),
                    ),
                  );
                }
                final docs = snapshot.data!.docs;


                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    docs.map((doc) async {
                      final data = doc.data() as Map<String, dynamic>;
                      String type = data['type'] as String? ?? '';
                      
                      if (type.isEmpty) {
                        type = await _getEstablishmentType(doc.id);
                        await favoritesRef.doc(doc.id).update({'type': type});
                      }
                      
                      return {
                        'id': doc.id,
                        'imagePath': data['imagePath'] ?? '',
                        'subtitle': data['subtitle'] ?? '',
                        'type': _normalizeType(type),
                      };
                    }).toList(),
                  ),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }


                    if (!futureSnapshot.hasData) {
                      return Center(
                        child: Text(
                          'No favorites yet',
                          style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      );
                    }


                    final allItems = futureSnapshot.data!;
                    final selectedCategory = categories[selectedCategoryIndex].label;
                    
                    final filteredItems = allItems.where((item) {
                      final itemType = item['type'] as String;
                      switch (selectedCategory) {
                        case 'Cafes':
                          return itemType == 'Cafe';
                        case 'Parks':
                          return itemType == 'Park';
                        case 'Resorts':
                          return itemType == 'Resort';
                        case 'Restaurants':
                          return itemType == 'Restaurant';
                        case 'Bars':
                          return itemType == 'Bar';
                        default:
                          return true;
                      }
                    }).toList();


                    if (filteredItems.isEmpty) {
                      return Center(
                        child: Text(
                          'No favorites yet',
                          style: TextStyle(fontSize: 18, color: isDark ? Colors.white54 : Colors.grey),
                        ),
                      );
                    }


                    final groupedByCity = _groupByCity(filteredItems);


                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: groupedByCity.length,
                      itemBuilder: (context, index) {
                        final cityName = groupedByCity.keys.elementAt(index);
                        final cityItems = groupedByCity[cityName]!;


                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    cityName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ViewAllScreen(
                                            title: cityName,
                                            items: cityItems,
                                            onTap: (cafeTitle) => _navigateToDetail(context, cafeTitle),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View all',
                                      style: TextStyle(
                                        color: Color(0xFF0C57E5),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _CityCarousel(
                              items: cityItems,
                              onUnfavorite: (id) async => await favoritesRef.doc(id).delete(),
                              onTap: (cafeTitle) => _navigateToDetail(context, cafeTitle),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;


    final Color selectedBackground = isDark ? const Color(0xFF0C57E5) : const Color(0xFF1764E8);
    final Color selectedText = Colors.white;
    final Color unselectedText = isDark ? Colors.white : Colors.black87;
    final Color unselectedIcon = isDark ? Colors.white : Colors.black54;


    return Material(
      color: selected
          ? selectedBackground
          : (isDark ? theme.colorScheme.surface : Colors.white),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? selectedText : unselectedIcon,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? selectedText : unselectedText,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _CityCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(String id) onUnfavorite;
  final Function(String cafeTitle) onTap;
  const _CityCarousel({
    required this.items,
    required this.onUnfavorite,
    required this.onTap,
  });


  @override
  State<_CityCarousel> createState() => _CityCarouselState();
}


class _CityCarouselState extends State<_CityCarousel> {
  late PageController _pageController;
  int _page = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.78);
    _pageController.addListener(() {
      final p = _pageController.page ?? 0.0;
      final i = p.round();
      if (i != _page && mounted) {
        setState(() => _page = i);
      }
    });
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Column(
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _CarouselFavoriteCard(
                  imagePath: data['imagePath'],
                  cafeTitle: data['id'],
                  subtitle: data['subtitle'],
                  onUnfavorite: () => widget.onUnfavorite(data['id']),
                  onTap: () => widget.onTap(data['id']),
                ),
              );
            },
          ),
        ),
        if (items.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) {
                final isActive = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: isActive ? 18 : 7,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0C57E5) : Colors.black26,
                    borderRadius: BorderRadius.circular(7),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}


class _CarouselFavoriteCard extends StatelessWidget {
  final String imagePath;
  final String cafeTitle;
  final String subtitle;
  final VoidCallback onUnfavorite;
  final VoidCallback onTap;


  const _CarouselFavoriteCard({
    required this.imagePath,
    required this.cafeTitle,
    required this.subtitle,
    required this.onUnfavorite,
    required this.onTap,
  });


  Stream<({double? average, int count})> getRatingInfo() {
    final ref = FirebaseFirestore.instance
        .collection('cafes')
        .doc(cafeTitle)
        .collection('ratings');
    return ref.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return (average: null, count: 0);
      final ratings = snapshot.docs
          .map((doc) => (doc['rating'] ?? 0).toDouble())
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return (average: avg, count: ratings.length);
    });
  }


  bool get isNetworkImage => imagePath.startsWith('http://') || imagePath.startsWith('https://');


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              imagePath.isNotEmpty
                  ? (isNetworkImage
                      ? Image.network(
                          imagePath,
                          width: double.infinity,
                          height: 195,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 195,
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 195,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 56, color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: 195,
                          fit: BoxFit.cover,
                        ))
                  : Container(
                      width: double.infinity,
                      height: 195,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 56, color: Colors.grey),
                    ),
              Container(
                height: 195,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(.82),
                      Colors.black.withOpacity(.18),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 14,
                child: StreamBuilder<({double? average, int count})>(
                  stream: getRatingInfo(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    final hasRating = info?.average != null && info!.count > 0;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            hasRating 
                                ? '${info.average!.toStringAsFixed(1)} Ratings'
                                : 'No Ratings',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 18,
                bottom: 32,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafeTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 22,
                bottom: 22,
                child: GestureDetector(
                  onTap: onUnfavorite,
                  child: const Icon(Icons.favorite, color: Colors.redAccent, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ViewAllScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Function(String cafeTitle) onTap;
  
  const ViewAllScreen({
    required this.title,
    required this.items,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0.5,
      ),
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xffF8F9FB),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No favorites yet',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final data = items[index];
                return _ViewAllFavoriteCard(
                  imagePath: data['imagePath'],
                  cafeTitle: data['id'],
                  subtitle: data['subtitle'],
                  onTap: () => onTap(data['id']),
                );
              },
            ),
    );
  }
}


class _ViewAllFavoriteCard extends StatelessWidget {
  final String imagePath;
  final String cafeTitle;
  final String subtitle;
  final VoidCallback onTap;


  const _ViewAllFavoriteCard({
    required this.imagePath,
    required this.cafeTitle,
    required this.subtitle,
    required this.onTap,
  });


  Stream<({double? average, int count})> getRatingInfo() {
    final ref = FirebaseFirestore.instance
        .collection('cafes')
        .doc(cafeTitle)
        .collection('ratings');
    return ref.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return (average: null, count: 0);
      final ratings = snapshot.docs
          .map((doc) => (doc['rating'] ?? 0).toDouble())
          .toList();
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return (average: avg, count: ratings.length);
    });
  }


  bool get isNetworkImage => imagePath.startsWith('http://') || imagePath.startsWith('https://');


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imagePath.isNotEmpty
                  ? (isNetworkImage
                      ? Image.network(
                          imagePath,
                          width: double.infinity,
                          height: 125,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: double.infinity,
                              height: 125,
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 125,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            );
                          },
                        )
                      : Image.asset(
                          imagePath,
                          width: double.infinity,
                          height: 125,
                          fit: BoxFit.cover,
                        ))
                  : Container(
                      width: double.infinity,
                      height: 125,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            Container(
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(.7),
                    Colors.black.withOpacity(.1),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 50,
              child: StreamBuilder<({double? average, int count})>(
                stream: getRatingInfo(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  final hasRating = info?.average != null && info!.count > 0;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          hasRating 
                              ? '${info.average!.toStringAsFixed(1)}'
                              : 'No',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 18,
              bottom: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cafeTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
