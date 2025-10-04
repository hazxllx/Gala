import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RideInfo {
  final IconData icon;
  final String type;
  final int durationMinutes;
  final String fare;

  RideInfo({
    required this.icon,
    required this.type,
    required this.durationMinutes,
    required this.fare,
  });
}

class ViewMorePage extends StatefulWidget {
  const ViewMorePage({super.key});

  @override
  State<ViewMorePage> createState() => _ViewMorePageState();
}

class _ViewMorePageState extends State<ViewMorePage> {
  late Timer _timer;
  late DateTime _departTime;
  int _selectedIndex = 0;

  final List<RideInfo> rides = [
    RideInfo(icon: Icons.directions_bus, type: "Jeepney", durationMinutes: 30, fare: "₱12"),
    RideInfo(icon: Icons.electric_rickshaw, type: "Tricycle", durationMinutes: 25, fare: "₱15"),
    RideInfo(icon: Icons.directions_bike, type: "Bike", durationMinutes: 20, fare: "Free"),
    RideInfo(icon: Icons.directions_walk, type: "Walk", durationMinutes: 45, fare: "Free"),
  ];

  @override
  void initState() {
    super.initState();
    _departTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _departTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

String _formatTime(DateTime time) {
  int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  String minute = time.minute.toString().padLeft(2, '0');
  String period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}


  @override
  Widget build(BuildContext context) {
    final selectedRide = rides[_selectedIndex];
    final arrivalTime = _departTime.add(Duration(minutes: selectedRide.durationMinutes));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Available Rides',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 330,
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
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
          // Rides Card
          Positioned(
            top: 310,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Rides and Fares',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Arrival times may vary. Traffic conditions, driver waiting times for passengers, and multiple stops along the route may affect the estimated arrival time. Be prepared for possible delays, especially during peak hours.',
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(rides.length, (idx) {
                      final ride = rides[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: idx == _selectedIndex ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(ride.icon, size: 28, color: Colors.blue),
                          title: Text(ride.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Fare: ${ride.fare}'),
                          trailing: Text('${ride.durationMinutes} mins', style: TextStyle(color: Colors.grey[600])),
                          onTap: () => setState(() => _selectedIndex = idx),
                        ),
                      );
                    }),
                    const SizedBox(height: 22),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ride type icons (toggle buttons can be added here)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: rides.map((ride) {
                                final idx = rides.indexOf(ride);
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedIndex = idx),
                                  child: CircleAvatar(
                                    backgroundColor: idx == _selectedIndex ? Colors.blue : Colors.grey[200],
                                    radius: 18,
                                    child: Icon(
                                      ride.icon,
                                      color: idx == _selectedIndex ? Colors.white : Colors.blueGrey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            // Location inputs (can use TextFields or Dropdowns in a full app)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('J. Hernandez Avenue'),
                                Divider(),
                                Text('JSCM+F4V, Padian St'),
                                Divider(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Depart at', style: TextStyle(color: Colors.grey[700])),
                                Row(
                                  children: [
                                    Text(
                                      // Live departure time (now)
                                      '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'
                                      ' ${DateTime.now().hour >= 12 ? "PM" : "AM"}',
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      // Today as MM/dd/yy
                                      '${DateTime.now().month.toString().padLeft(2, '0')}/'
                                      '${DateTime.now().day.toString().padLeft(2, '0')}/'
                                      '${DateTime.now().year.toString().substring(2)}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                'You will arrive around\n${_formatTime(arrivalTime)} in ${selectedRide.durationMinutes} mins',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
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
          ),
        ],
      ),
    );
  }
}
