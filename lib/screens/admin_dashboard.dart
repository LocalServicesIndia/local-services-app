import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Future<Map<String, dynamic>> getStats() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final bookings = await FirebaseFirestore.instance.collection('bookings').get();

    double revenue = 0;
    for (var doc in bookings.docs) {
      final data = doc.data();
      final amount = double.tryParse(data['amount']?.toString() ?? '0') ?? 0;
      revenue += amount;
    }

    return {
      'users': users.docs.length,
      'bookings': bookings.docs.length,
      'revenue': revenue,
    };
  }

  Future<List<Map<String, dynamic>>> getPendingProviders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'provider_pending')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'email': doc['email'],
    }).toList();
  }

  void approveProvider(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': 'provider'});
    setState(() {});
  }

  void deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
          children: [
            DrawerHeader(
              child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
              decoration: BoxDecoration(color: Colors.blue),
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
      body: FutureBuilder(
        future: Future.wait([
          getStats(),
          getPendingProviders(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final stats = snapshot.data![0] as Map<String, dynamic>;
          final pending = snapshot.data![1] as List<Map<String, dynamic>>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Platform Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    statCard("Users", stats['users'].toString()),
                    statCard("Bookings", stats['bookings'].toString()),
                    statCard("Revenue", "₹${stats['revenue'].toStringAsFixed(2)}"),
                  ],
                ),
                SizedBox(height: 20),
                Text("Pending Provider Approvals", style: TextStyle(fontSize: 20)),
                ...pending.map((p) => ListTile(
                  title: Text(p['email']),
                  trailing: ElevatedButton(
                    child: Text("Approve"),
                    onPressed: () => approveProvider(p['id']),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget statCard(String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: 120,
        height: 100,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
