import 'package:flutter/material.dart';

class CaramelMenuPage extends StatefulWidget {
  const CaramelMenuPage({super.key});

  @override
  _CaramelMenuPageState createState() => _CaramelMenuPageState();
}

class _CaramelMenuPageState extends State<CaramelMenuPage> {
  int selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    // Text color is white in dark mode, black in light mode
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color accentColor = const Color(0xFF0B55A0); // Blue
    final Color subtitleColor = isDark ? Colors.grey[400]! : accentColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ================================
          // FIXED TOP NETWORK BACKGROUND
          // ================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel1.jpg",
                  ),
                  fit: BoxFit.cover,
                  colorFilter: isDark
                      ? ColorFilter.mode(
                          Colors.black.withOpacity(0.45),
                          BlendMode.darken,
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ================================
          // ROUND TOP MAIN SHEET
          // ================================
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.15),
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // TITLE
                    Text(
                      'Caramel Menu',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CATEGORY SELECTOR
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          categoryTab('Cakes', 0, textColor, subtitleColor,
                              isDark),
                          categoryTab('Hot Coffee', 1, textColor, subtitleColor,
                              isDark),
                          categoryTab('Iced Coffee', 2, textColor,
                              subtitleColor, isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      thickness: 1,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                    ),

                    // GRID ITEMS
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 22,
                        childAspectRatio: 0.83,
                        children: buildMenuItems(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================================
          // BACK BUTTON
          // ================================
          Positioned(
            top: 55,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // ================================
          // TITLE ON IMAGE
          // ================================
          Positioned(
            top: 130,
            left: 40,
            child: Text(
              'Caramel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 6,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CATEGORY TAB (Fixed Text Color Logic)
  Widget categoryTab(String title, int index, Color activeColor,
      Color inactiveColor, bool isDark) {
    bool isSelected = selectedCategoryIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () => setState(() => selectedCategoryIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: isSelected
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white : const Color(0xFF0B55A0),
                      width: 2,
                    ),
                  ),
                )
              : null,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              fontWeight: FontWeight.bold,
              fontSize: 15,
              // Use textColor passed from build() which is white/black based on theme
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ),
      ),
    );
  }

  // BUILD MENU GRID ITEMS
  List<Widget> buildMenuItems(bool isDark) {
    if (selectedCategoryIndex == 0) return _cakes(isDark);
    if (selectedCategoryIndex == 1) return _hotCoffee(isDark);
    return _icedCoffee(isDark);
  }

  // ================================
  // CAKES
  // ================================
  List<Widget> _cakes(bool isDark) => [
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/choco_garden.jpg",
          "Choco Garden 8x8 – ₱500",
          "Chocolate cake with creamy layers",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/mocha_garden.jpg",
          "Mocha Garden 8x8 – ₱500",
          "Coffee-flavored layered cake",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/pink_blossom.jpg",
          "Pink Blossom Cake 8\" – ₱600",
          "Pretty pink buttercream delight",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/triple_black_forest.png",
          "Triple Black Forest – ₱525",
          "Chocolate + cherries + whipped cream",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/yema_cake.jpg",
          "Yema Cake – ₱95",
          "Soft chiffon + yema frosting",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/cakes/yema_tub.jpg",
          "Yema Tub – ₱90",
          "Creamy yema in a tub",
        ),
      ];

  // ================================
  // HOT COFFEE
  // ================================
  List<Widget> _hotCoffee(bool isDark) => [
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/americano.jpg",
          "Americano – Jr ₱80 / Full ₱90",
          "Bold + smooth espresso blend",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/cafe_latte.jpg",
          "Cafe Latte – ₱135",
          "Espresso + steamed milk",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/cappuccino.jpg",
          "Cappuccino – ₱135",
          "Foamy espresso classic",
        ),
      ];

  // ================================
  // ICED COFFEE
  // ================================
  List<Widget> _icedCoffee(bool isDark) => [
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/ice_caramel_latte.jpg",
          "Iced Caramel Macchiato – ₱165",
          "Caramel + milk + espresso",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/ice_mocha_latte.jpg",
          "Iced Mocha – ₱160",
          "Chocolate + espresso + milk",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/ice_spanish_latte.jpg",
          "Iced Spanish Latte – ₱155",
          "Sweet creamy iced latte",
        ),
        buildMenuItem(
          isDark,
          "https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/caramel/caramel_menu/coffee/iced_ube_latte.jpg",
          "Iced Dirty Ube Mocha – ₱160",
          "Ube + mocha + espresso",
        ),
      ];

  // ================================
  // MENU ITEM CARD + FIXED DIALOG UI
  // ================================
  Widget buildMenuItem(
      bool isDark, String url, String title, String subtitle) {
    final Color titleColor = isDark ? Colors.white : Colors.black;
    final Color subtitleColor =
        isDark ? Colors.grey[300]! : const Color(0xFF0B55A0);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.75),
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 20, color: titleColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 240,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                color: subtitleColor,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              height: 240,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 50),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TITLE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // SUBTITLE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE CARD
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                url,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: isDark ? Colors.white10 : Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: subtitleColor,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // TITLE
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: titleColor,
            ),
          ),

          const SizedBox(height: 4),

          // SUBTITLE
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
