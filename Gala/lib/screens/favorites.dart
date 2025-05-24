import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FavoritesPage extends StatelessWidget {
  FavoritesPage({super.key});

  final Map<String, List<CafeCard>> groupedFavorites = {
    'Naga City': [
      CafeCard(
        imagePath: 'assets/arco_diez.jpeg',
        title: 'Arco Diez Cafe',
        subtitle: 'Km. 10 Pacol Rd',
        rating: 4.8,
      ),
      CafeCard(
        imagePath: 'assets/harina.jpeg',
        title: 'Harina Cafe',
        subtitle: 'Narra St, Naga',
        rating: 4.1,
      ),
    ],
    'Pili': [
      CafeCard(
        imagePath: 'assets/harina.jpeg',
        title: 'Liters Cafe',
        subtitle: 'San Isidro, Pili',
        rating: 4.6,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children:
              groupedFavorites.entries.map((entry) {
                final String city = entry.key;
                final List<CafeCard> cafes = entry.value;
                final PageController controller = PageController(
                  viewportFraction: 0.85,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          city,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'View all',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 210,
                      child: PageView.builder(
                        controller: controller,
                        itemCount: cafes.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              double scale = 1.0;
                              if (controller.position.haveDimensions) {
                                scale = controller.page! - index;
                                scale = (1 - (scale.abs() * 0.3)).clamp(
                                  0.0,
                                  1.0,
                                );
                              }
                              return Transform.scale(
                                scale: scale,
                                child: cafes[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: cafes.length,
                        effect: WormEffect(dotHeight: 8, dotWidth: 8),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}

class CafeCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double rating;

  const CafeCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.rating,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Match this with your PageView height
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        child: Column(
          children: [
            // IMAGE SECTION
            Expanded(
              flex: 4,
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // DETAILS SECTION
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + RATING IN ONE ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text('$rating'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
