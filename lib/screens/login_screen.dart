import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import all dashboards
import 'customer_dashboard.dart';
import 'provider_dashboard.dart';
import 'support_dashboard.dart';
import 'partner_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> login() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = userCredential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final role = doc.data()!['role'];
        if (role == 'customer') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerDashboard()));
        } else if (role == 'provider') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProviderDashboard()));
        } else if (role == 'support') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SupportDashboard()));
        } else if (role == 'partner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PartnerDashboard()));
        } else if (role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
        } else {
          setState(() => _error = 'Unknown role.');
        }
      } else {
        setState(() => _error = 'No user record found.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Login failed.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
