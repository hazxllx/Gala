import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ViewMorePage extends StatefulWidget {
  const ViewMorePage({super.key});

  @override
  _ViewMorePageState createState() => _ViewMorePageState();
}

class _ViewMorePageState extends State<ViewMorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
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
            left: 0, // margin from left
            right: 0, // margin from right
            bottom: 16, // margin from bottom
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ), // more vertical padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Rides and Fares',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Arrival times may vary. Traffic conditions, driver waiting times for passengers, and multiple stops along the route may affect the estimated arrival time. Be prepared for possible delays, especially during peak hours.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      RideOption(
                        icon: Icons.directions_bus,
                        type: "Jeepney",
                        time: "5 mins",
                        fare: "₱12",
                      ),
                      RideOption(
                        icon: Icons.electric_rickshaw,
                        type: "Tricycle",
                        time: "3 mins",
                        fare: "₱15",
                      ),
                      RideOption(
                        icon: Icons.directions_bike,
                        type: "Bike",
                        time: "4 mins",
                        fare: "Free",
                      ),
                      RideOption(
                        icon: Icons.directions_walk,
                        type: "Walk",
                        time: "6 mins",
                        fare: "Free",
                      ),
                      SizedBox(height: 16),
                      RideSelectorCard(),
                    ],
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

// RideOption widget outside the RoutePage widget
class RideOption extends StatelessWidget {
  final IconData icon;
  final String type;
  final String time;
  final String fare;

  RideOption({
    required this.icon,
    required this.type,
    required this.time,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 28, color: Colors.blue),
        title: Text(type, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Fare: $fare'),
        trailing: Text(time, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

class RideSelectorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Ride type icons (toggle buttons can be added here)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.directions_bus, color: Colors.black),
                Icon(Icons.electric_rickshaw, color: Colors.black),
                Icon(Icons.directions_bike, color: Colors.black),
                Icon(Icons.directions_walk, color: Colors.black),
              ],
            ),
            SizedBox(height: 16),
            // Location inputs (can use TextFields or Dropdowns in a full app)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('J. Hernandez Avenue'),
                Divider(),
                Text('JSCM+F4V, Padian St'),
                Divider(),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Depart at', style: TextStyle(color: Colors.grey[700])),
                Row(
                  children: [
                    Text('10:47 AM'),
                    SizedBox(width: 10),
                    Text('03/08/25'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text(
                'You will arrive around\n10:50 AM in 3 mins',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
