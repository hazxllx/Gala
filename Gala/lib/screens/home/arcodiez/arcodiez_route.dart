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
    return Scaffold(
      backgroundColor: Colors.white, // Black background as requested
      body: Stack(
        children: [
          // Background Map with Red Location Pin
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 420,
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

          // White Container with rounded top corners below the map
          Positioned(
            top: 380,
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
                    height:
                        900, // or more, enough to cover all Positioned widgets bottom
                    child: Stack(
                      clipBehavior: Clip.antiAlias,
                      children: [
                        Positioned(
                          left: 1,
                          top: 330,
                          child: Container(
                            width: 144,
                            height: 42,
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
                                  width: 112,
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
                          left: 34,
                          top: 400, // Adjust top to fit below Directions
                          child: Container(
                            width: 340,
                            height: 425,
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
                            // Insert your content Container here:
                            child: Container(
                              width: 400,
                              height: 390,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 10,
                                    top: 31,
                                    child: Container(
                                      width: 350,
                                      height: 126,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(
                                          0,
                                        ), // corrected from withValues
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
                                                width: 24,
                                                height: 24,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(),
                                                child: Stack(
                                                  children: [
                                                    // You had Positioned(left: undefined, top: undefined) here, remove or fix
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
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
                                                      0xFF141414,
                                                    ),
                                                    fontSize: 14,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.71,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  '5 min, 400m',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF3D4C5B,
                                                    ),
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
                                    left: 10,
                                    top: 157,
                                    child: Container(
                                      width: 300,
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
                                                width: 50,
                                                height: 50,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      left: 14,
                                                      top: 13,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            image: AssetImage(
                                                              'assets/images/tricycle.png',
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'via Peñafrancia St & Pacol Rd',
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF141414,
                                                    ),
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
                                                      0xFF3D4C5B,
                                                    ),
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
                                                      0xFF3D4C5B,
                                                    ),
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
                                    top: 271,
                                    child: Container(
                                      width: 390,
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
                                    left: 10,
                                    top: 318,
                                    child: Container(
                                      width: 300,
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
                                                  color: const Color(
                                                    0xFFEFF2F4,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            'assets/images/tricycle.png',
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Tricycle',
                                                      style: TextStyle(
                                                        color: const Color(
                                                          0xFF141414,
                                                        ),
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
                                                          0xFF3D4C5B,
                                                        ),
                                                        fontSize: 12,
                                                        fontFamily: 'Inter',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.75,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: 20,
                                    top: 0,
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
                          left: 290,
                          top: 348,
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
                              width: 90,
                              height: 24,
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
                          left: 11,
                          top: 293,
                          child: Container(
                            width: 332,
                            height: 430,
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
                                  top: 7,
                                  child: Container(
                                    width: 390,
                                    height: 47,
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
                          left: 30,
                          top: 40,
                          child: SizedBox(
                            width: 314,
                            height: 50,
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
                          left: 30,
                          top: 100,
                          child: Container(
                            width: 350,
                            height: 74,
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
                          left: 30,
                          top: 143,
                          child: Container(
                            width: 350,
                            height: 50,
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
                          left: 45,
                          top: 158,
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
                          left: 72,
                          top: 149,
                          child: SizedBox(
                            width: 269,
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
                          left: 45,
                          top: 110,
                          child: SizedBox(
                            width: 323,
                            height: 18,
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
                          left: 30,
                          top: 220,
                          child: Container(
                            width: 350,
                            height: 74,
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
                          left: 30,
                          top: 260,
                          child: Container(
                            width: 350,
                            height: 50,
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
                          left: 45,
                          top: 275,
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
                          left: 72,
                          top: 265,
                          child: SizedBox(
                            width: 269,
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
                          left: 45,
                          top: 228,
                          child: SizedBox(
                            width: 323,
                            height: 18,
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
