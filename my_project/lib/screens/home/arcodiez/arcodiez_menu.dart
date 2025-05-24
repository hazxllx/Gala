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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/menu1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // White Container
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 30,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Scrollable Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          categoryTab('Hot Non Coffee', 0),
                          categoryTab('Cold Non Coffee', 1),
                          categoryTab('Refreshment', 2),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    Center(
                      child: Divider(
                        thickness: 1,
                        color: const Color.fromARGB(255, 207, 207, 207),
                      ),
                    ),

                    // Scrollable Grid Menu
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.9,
                        children: buildMenuItems(),
                      ),
                    ),

                    // Next Button
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1562A1), // Start color
                            Color(0xFF0A426F), // End color
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (selectedCategoryIndex < 2) {
                              selectedCategoryIndex++;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white, // White text
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cafe Name and Back Button
          Positioned(
            top: 70,
            left: 24,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            top: 130,
            left: 40,
            child: Text(
              'Arco Diez Menu',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildMenuItems() {
    if (selectedCategoryIndex == 0) {
      // Hot Non Coffee
      return [
        buildMenuItem(
          'assets/images/tea_bag.png',
          'Tea Bags - ₱60',
          'Ask for availability',
        ),
        buildMenuItem(
          'assets/images/chocolate.png',
          'Chocolate Tablea - ₱90',
          'Batangas cacao + milk',
        ),
        buildMenuItem(
          'assets/images/lemon.png',
          'Lemonade - ₱100',
          'Kalamansi juice + hot water',
        ),
        buildMenuItem(
          'assets/images/coffee.png',
          'Iced Chocolate Latte - ₱130',
          'Chocolate powder + steamed milk',
        ),
        buildMenuItem(
          'assets/images/matcha.png',
          'Matcha Latte - ₱140',
          'Green tea matcha + steamed milk',
        ),
      ];
    } else if (selectedCategoryIndex == 1) {
      // Cold Non Coffee
      return [
        buildMenuItem(
          'assets/images/clatte.png',
          'Chocolate Latte - ₱150',
          'Chocolate Powder + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mlatte.png',
          'Matcha Latte - ₱160',
          'Green Tea Matcha + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mclatte.png',
          'Matcha Chocolate Latte - ₱160',
          'Green Tea Matcha + Chocolate Powder + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/slatte.png',
          'Strawberry Latte - ₱180',
          'Strawberry Puree + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mglatte.png',
          'Mango Latte - ₱180',
          'Mango Puree + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mslatte.png',
          'Matcha Strawberry - ₱190',
          'Green Tea Matcha + Strawberry Puree + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mm.png',
          'Matcha Mango - ₱190',
          'Green Tea Matcha + Mango Puree + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/blatte.png',
          'Banana Latte - ₱180',
          'Banana Puree + Steamed Milk + Ice',
        ),
        buildMenuItem(
          'assets/images/mb.png',
          'Matcha Banana - ₱190',
          'Green Tea Matcha + Banana Puree + Steamed Milk + Ice',
        ),
      ];
    } else {
      // Refreshment
      return [];
    }
  }

  // Category Tab Widget
  Widget categoryTab(String title, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color:
                selectedCategoryIndex == index
                    ? Colors.black
                    : Color.fromARGB(255, 201, 152, 80),
          ),
        ),
      ),
    );
  }

  // Menu Item Widget
  Widget buildMenuItem(String imagePath, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.8), // dark background
          builder: (BuildContext context) {
            return Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button (Top Right, inside)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Image with side padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

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
                          ),
                        ),
                      ),

                      SizedBox(height: 6),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 11.3,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color.fromARGB(255, 201, 152, 80),
            ),
          ),
        ],
      ),
    );
  }
}
