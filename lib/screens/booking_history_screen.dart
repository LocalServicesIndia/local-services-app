import 'package:flutter/material.dart';

class BookingHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> history = [
      {
        'service': 'Plumber',
        'date': 'June 20, 2025',
        'price': '₹400',
      },
      {
        'service': 'Electrician',
        'date': 'June 22, 2025',
        'price': '₹300',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final booking = history[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('${booking['service']} - ${booking['price']}'),
              subtitle: Text('${booking['date']}'),
            ),
          );
        },
      ),
    );
  }
}

