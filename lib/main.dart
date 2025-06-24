import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/customer_dashboard.dart';
import 'screens/provider_dashboard.dart';
import 'screens/support_dashboard.dart';
import 'screens/partner_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(LocalServicesApp());
}

class LocalServicesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Services App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return LoginScreen(); // Fallback
            }

            final role = userSnapshot.data!['role'];

            switch (role) {
              case 'admin':
                return AdminDashboard();
              case 'provider':
                return ProviderDashboard();
              case 'support':
                return SupportDashboard();
              case 'partner':
                return PartnerDashboard();
              case 'customer':
              default:
                return CustomerDashboard();
            }
          },
        );
      },
    );
  }
}
