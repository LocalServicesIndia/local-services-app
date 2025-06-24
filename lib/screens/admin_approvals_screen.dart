import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminApprovalsScreen extends StatelessWidget {
  void approveProvider(DocumentSnapshot doc, BuildContext context) async {
    final data = doc.data() as Map<String, dynamic>;

    // Add to 'users' collection with role = provider
    await FirebaseFirestore.instance.collection('users').add({
      'name': data['name'],
      'phone': data['phone'],
      'serviceType': data['serviceType'],
      'area': data['area'],
      'role': 'provider',
      'createdAt': Timestamp.now(),
    });

    // Remove from pending list
    await FirebaseFirestore.instance.collection('pending_providers').doc(doc.id).delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Provider approved')));
  }

  void rejectProvider(DocumentSnapshot doc, BuildContext context) async {
    await FirebaseFirestore.instance.collection('pending_providers').doc(doc.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Provider rejected')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Provider Approvals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pending_providers').orderBy('submittedAt').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final providers = snapshot.data!.docs;

          if (providers.isEmpty) {
            return Center(child: Text('No pending requests'));
          }

          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final data = provider.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['name']),
                  subtitle: Text('${data['serviceType']} - ${data['area']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => approveProvider(provider, context),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => rejectProvider(provider, context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
