import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int selectedCategoryIndex = 0; // 0 = Hot Non Coffee, 1 = Cold Non Coffee

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final containerColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFF0B55A0); 

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/menu1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.0),
              ),
            ),
          ),

          // White/Dark Container
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drinks Title
                    Center(
                      child: Text(
                        'Drinks',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scrollable Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          categoryTab('Hot Non Coffee', 0, textColor, accentColor),
                          categoryTab('Cold Non Coffee', 1, textColor, accentColor),
                          categoryTab('Refreshment', 2, textColor, accentColor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Divider(
                        thickness: 1,
                        color: isDarkMode ? Colors.white24 : const Color.fromARGB(255, 207, 207, 207),
                      ),
                    ),

                    // Scrollable Grid Menu
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.85,
                        children: buildMenuItems(textColor, accentColor, isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildMenuItems(Color textColor, Color accentColor, bool isDarkMode) {
    if (selectedCategoryIndex == 0) {
      // Hot Non Coffee
      return [
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/tea_bag.png',
          'Tea Bags - ₱60',
          'Ask for availability',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/chocolate.png',
          'Chocolate Tablea - ₱90',
          'Batangas cacao + milk',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/lemon.png',
          'Lemonade - ₱100',
          'Kalamansi juice + hot water',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/coffee.png',
          'Iced Chocolate Latte - ₱130',
          'Chocolate powder + steamed milk',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/matcha.png',
          'Matcha Latte - ₱140',
          'Green tea matcha + steamed milk',
          textColor,
          accentColor,
          isDarkMode,
        ),
      ];
    } else if (selectedCategoryIndex == 1) {
      // Cold Non Coffee
      return [
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/clatte.png',
          'Chocolate Latte - ₱150',
          'Chocolate Powder + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mlatte.png',
          'Matcha Latte - ₱160',
          'Green Tea Matcha + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mclatte.png',
          'Matcha Chocolate Latte - ₱160',
          'Green Tea Matcha + Chocolate Powder + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mslatte.png',
          'Strawberry Latte - ₱180',
          'Strawberry Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mglatte.png',
          'Mango Latte - ₱180',
          'Mango Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mslatte.png',
          'Matcha Strawberry - ₱190',
          'Green Tea Matcha + Strawberry Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mm.png',
          'Matcha Mango - ₱190',
          'Green Tea Matcha + Mango Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/blatte.png',
          'Banana Latte - ₱180',
          'Banana Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
        buildMenuItem(
          'https://gala-app-images.s3.ap-southeast-2.amazonaws.com/naga_cafe/arco_menu/mb.png',
          'Matcha Banana - ₱190',
          'Green Tea Matcha + Banana Puree + Steamed Milk + Ice',
          textColor,
          accentColor,
          isDarkMode,
        ),
      ];
    } else {
      // Refreshment
      return [];
    }
  }

  // Category Tab Widget
  Widget categoryTab(String title, int index, Color textColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: selectedCategoryIndex == index
                ? Border(bottom: BorderSide(color: accentColor, width: 2))
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              // When selected: textColor (White in Dark Mode, Black in Light Mode)
              // When unselected: accentColor (Blue)
              color: selectedCategoryIndex == index ? textColor : accentColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  // Menu Item Widget
  Widget buildMenuItem(String imagePath, String title, String subtitle, Color textColor, Color accentColor, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.8),
          builder: (BuildContext context) {
            return Dialog(
              elevation: 0,
              backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24,
                          color: isDarkMode ? Colors.white70 : Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Network Image with padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imagePath,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 250,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: accentColor,
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
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 50, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: isDarkMode ? Colors.white10 : Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
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
                    color: isDarkMode ? Colors.white10 : Colors.grey[300],
                    child: Icon(Icons.broken_image, size: 40, color: Colors.grey[600]),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
