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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top: Map + Back Button
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.38,
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
                Positioned(
                  top: 12,
                  left: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.93),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            // Info Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, left: 0, right: 0, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      child: Text(
                        'Arco Diez Cafe Location',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // Current Location Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                      child: _locationInfoCard(
                        title: 'Current location',
                        subtitle: 'J. Hernandez Avenue, Naga, Camarines Sur',
                        iconPath: 'assets/images/location.png',
                        bgColor: Color(0xFF0B55A0),
                        iconBgColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Destination Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                      child: _locationInfoCard(
                        title: 'Destination',
                        subtitle: 'Arco Diez, Km. 10 Pacol Rd, Naga, 4400',
                        iconPath: 'assets/images/location.png',
                        bgColor: Color.fromARGB(255, 6, 62, 118),
                        iconBgColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 18),

                    // Directions + "View more"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Directions',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewMorePage(),
                                ),
                              );
                            },
                            child: Text(
                              'View more...',
                              style: TextStyle(
                                color: Color(0xFF025582),
                                fontSize: 15,
                                fontFamily: 'Work Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),

                    // Jeepney/Walk Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEFF2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.directions_walk,
                                    size: 26,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Walk to Pacol Jeep Terminal, J5CM+FVF, Padian St, Naga, Camarines Sur',
                                      style: TextStyle(
                                        color: Color(0xFF141414),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '35 min, 400m',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Tricycle Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEFF2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/tricycle.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'via Peñafrancia St & Pacol Rd',
                                      style: TextStyle(
                                        color: Color(0xFF141414),
                                        fontSize: 14.8,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '25 min (10.2 km)',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Fastest route, the usual traffic',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Fares Section
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 8, top: 6),
                      child: Text(
                        'Estimated Public Transit Fares',
                        style: TextStyle(
                          color: Color(0xFF141414),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEFF2F4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/tricycle.png',
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tricycle',
                                      style: TextStyle(
                                        color: Color(0xFF141414),
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Regular: P20   |   PWD & Student: P15',
                                      style: TextStyle(
                                        color: Color(0xFF3D4C5B),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Location Card Widget
  Widget _locationInfoCard({
    required String title,
    required String subtitle,
    required String iconPath,
    required Color bgColor,
    required Color iconBgColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Image.asset(iconPath, width: 18, height: 18),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      fontSize: 15.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.90),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      fontSize: 13.7,
                    ),
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
