import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerDashboard extends StatelessWidget {
  final String partnerEmail = FirebaseAuth.instance.currentUser!.email!;

  Future<Map<String, dynamic>> getPartnerStats() async {
    final bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('referredBy', isEqualTo: partnerEmail)
        .get();

    int totalReferrals = bookings.docs.length;
    double totalSales = 0;
    double commission = 0;

    for (var doc in bookings.docs) {
      final data = doc.data();
      final amount = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
      totalSales += amount;
      commission += amount * 0.10; // 10% commission
    }

    return {
      'referrals': totalReferrals,
      'sales': totalSales,
      'commission': commission,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partner Dashboard'),
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
              child: Text('Partner Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
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
        future: getPartnerStats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                statCard('Total Referrals', stats['referrals'].toString(), Icons.people),
                statCard('Sales Generated', '₹${stats['sales'].toStringAsFixed(2)}', Icons.shopping_cart),
                statCard('Commission Earned', '₹${stats['commission'].toStringAsFixed(2)}', Icons.monetization_on),
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

