import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'booking_history_screen.dart';
import 'provider_registration_screen.dart';

class CustomerDashboard extends StatelessWidget {
  final List<Map<String, String>> services = [
    {'name': 'Plumber', 'image': 'https://i.imgur.com/XScsB9k.gif'},
    {'name': 'Electrician', 'image': 'https://i.imgur.com/VJxTzPP.gif'},
    {'name': 'House/PG for Rent', 'image': 'https://i.imgur.com/dosozdU.gif'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: Text('Become a Service Provider'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProviderRegistrationScreen()),
                );
              },
            ),
            ListTile(
              title: Text('My Bookings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: services.map((service) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(serviceName: service['name']!),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(service['image']!, height: 100),
                    SizedBox(height: 8),
                    Text(
                      service['name']!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
