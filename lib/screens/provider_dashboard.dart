import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderDashboard extends StatelessWidget {
  final String providerEmail = FirebaseAuth.instance.currentUser!.email!;

  Future<Map<String, dynamic>> getProviderStats() async {
    final bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('providerEmail', isEqualTo: providerEmail)
        .get();

    int completed = 0;
    double earnings = 0;
    int pending = 0;

    for (var doc in bookings.docs) {
      final data = doc.data();
      final status = data['status'] ?? 'pending';
      final amount = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;

      if (status == 'completed') {
        completed++;
        earnings += amount;
      } else {
        pending++;
      }
    }

    return {
      'completed': completed,
      'earnings': earnings,
      'pending': pending,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Provider Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getProviderStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                statCard('Completed Jobs', data['completed'].toString(), Icons.check_circle),
                statCard('Earnings', '₹${data['earnings'].toStringAsFixed(2)}', Icons.attach_money),
                statCard('Pending Jobs', data['pending'].toString(), Icons.pending_actions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget statCard(String label, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 20, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

