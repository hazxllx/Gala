import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'view_more.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Map with Red Location Pin
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.5, // Adjusted to fit mobile screen
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(13.6608, 123.2624),
                  zoom: 15.0,
                  maxBounds: LatLngBounds(
                    LatLng(13.0, 122.5),
                    LatLng(14.0, 123.8),
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(13.6608, 123.2624),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // White Container with rounded top corners below the map
          Positioned(
            top: screenHeight * 0.45, // Adjusted to fit below the map
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: screenHeight * 1.2, // Adjusted height for content
                    child: Stack(
                      clipBehavior: Clip.antiAlias,
                      children: [
                        Positioned(
                          left: screenWidth * 0.002,
                          top: screenHeight * 0.35, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.35,
                            height: screenHeight * 0.05,
                            padding: const EdgeInsets.only(
                              top: 16,
                              left: 30,
                              right: 16,
                              bottom: 3,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: screenWidth * 0.3,
                                  child: Text(
                                    'Directions',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.085,
                          top: screenHeight * 0.42, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.85,
                            height: screenHeight * 0.5,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Container(
                              width: screenWidth * 0.85,
                              height: screenHeight * 0.46,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: screenWidth * 0.025,
                                    top: screenHeight * 0.02, // Adjusted from 0.04 for better spacing
                                    child: Container(
                                      width: screenWidth * 0.8,
                                      height: screenHeight * 0.15,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEFF2F4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.directions_walk,
                                                size: 24,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Walk to Pacol Jeep Terminal, J5CM+FVF, Padian St, Naga, Camarines Sur',
                                                  style: TextStyle(
                                                    color: const Color(
                                                        0xFF141414),
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.71,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '5 min, 400m',
                                                  style: TextStyle(
                                                    color: const Color(
                                                        0xFF3D4C5B),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.75,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: screenWidth * 0.025,
                                    top: screenHeight * 0.12, // Adjusted from 0.19 for better spacing
                                    child: Container(
                                      width: screenWidth * 0.8,
                                      height: screenHeight * 0.15,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFEFF2F4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/tricycle.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'via Peñafrancia St & Pacol Rd',
                                                  style: TextStyle(
                                                    color: const Color(
                                                        0xFF141414),
                                                    fontSize: 14.8,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.65,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '21 min (10.2 km)',
                                                  style: TextStyle(
                                                    color: const Color(
                                                        0xFF3D4C5B),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.75,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Fastest route, the usual traffic',
                                                  style: TextStyle(
                                                    color: const Color(
                                                        0xFF3D4C5B),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.75,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: 0,
                                    top: screenHeight * 0.25, // Adjusted from 0.32 for better spacing
                                    child: Container(
                                      width: screenWidth * 0.85,
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        bottom: 8,
                                      ),
                                      child: Text(
                                        'Estimated Public Transit Fares',
                                        style: TextStyle(
                                          color: const Color(0xFF141414),
                                          fontSize: 16,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.44,
                                        ),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: screenWidth * 0.025,
                                    top: screenHeight * 0.30, // Adjusted from 0.38 for better spacing
                                    child: Container(
                                      width: screenWidth * 0.8,
                                      height: screenHeight * 0.1,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: ShapeDecoration(
                                                  color: const Color(0xFFEFF2F4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'assets/images/tricycle.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Tricycle',
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF141414),
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      height: 1.71,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Regular: P20  |  PWD & Student: P15',
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF3D4C5B),
                                                      fontSize: 12,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.75,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: screenWidth * 0.05,
                                    top: screenHeight * 0.0, // Adjusted for better spacing
                                    child: Text(
                                      'Get there with Jeepney',
                                      style: TextStyle(
                                        color: const Color(0xFF141414),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700,
                                        height: 1.44,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.73,
                          top: screenHeight * 0.38, // Adjusted for better spacing
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewMorePage(),
                                ),
                              );
                            },
                            child: Container(
                              width: screenWidth * 0.23,
                              height: screenHeight * 0.03,
                              alignment: Alignment.centerRight,
                              child: Text(
                                'View more...',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF025582),
                                  fontSize: 15,
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w400,
                                  height: 1.60,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.028,
                          top: screenHeight * 0.30, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.83,
                            height: screenHeight * 0.51,
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white.withValues(alpha: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: screenHeight * 0.01,
                                  child: Container(
                                    width: screenWidth * 0.85,
                                    height: screenHeight * 0.06,
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.075,
                          top: screenHeight * 0.02, // Adjusted for better spacing
                          child: SizedBox(
                            width: screenWidth * 0.79,
                            height: screenHeight * 0.06,
                            child: Text(
                              'Arco Diez Cafe Location',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                height: 1.07,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.075,
                          top: screenHeight * 0.10, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.875,
                            height: screenHeight * 0.087,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF0B55A0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.075,
                          top: screenHeight * 0.15, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.875,
                            height: screenHeight * 0.06,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 6.30,
                                  offset: Offset(0, 2),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.112,
                          top: screenHeight * 0.167, // Adjusted for better spacing
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/location.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.18,
                          top: screenHeight * 0.157, // Adjusted for better spacing
                          child: SizedBox(
                            width: screenWidth * 0.673,
                            child: Text(
                              'J. Hernandez Avenue, Naga, Camarines Sur',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 10),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 2.92,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.112,
                          top: screenHeight * 0.132, // Adjusted for better centering
                          child: SizedBox(
                            width: screenWidth * 0.808,
                            height: screenHeight * 0.022,
                            child: Text(
                              'Current location',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.53,
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.075,
                          top: screenHeight * 0.24, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.875,
                            height: screenHeight * 0.087,
                            decoration: ShapeDecoration(
 color: const Color.fromARGB(255, 6, 62, 118),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          left: screenWidth * 0.075,
                          top: screenHeight * 0.29, // Adjusted for better spacing
                          child: Container(
                            width: screenWidth * 0.875,
                            height: screenHeight * 0.06,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 6.30,
                                  offset: Offset(0, 2),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.112,
                          top: screenHeight * 0.305, // Adjusted for better spacing
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/location.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.18,
                          top: screenHeight * 0.295, // Adjusted for better spacing
                          child: SizedBox(
                            width: screenWidth * 0.673,
                            child: Text(
                              'Arco Diez, Km. 10 Pacol Rd, Naga, 4400',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 10),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 2.92,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: screenWidth * 0.112,
                          top: screenHeight * 0.28, // Adjusted for better centering
                          child: SizedBox(
                            width: screenWidth * 0.808,
                            height: screenHeight * 0.022,
                            child: Text(
                              'Destination',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.53,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}