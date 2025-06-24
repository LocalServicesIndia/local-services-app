import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String role = 'support'; // default

  final List<String> roles = ['support', 'partner'];

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$role user added successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Support / Partner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'User Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => email = val.trim(),
                validator: (val) => val == null || val.isEmpty ? 'Enter a valid email' : null,
              ),
              DropdownButtonFormField<String>(
                value: role,
                onChanged: (val) => setState(() => role = val!),
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Add User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
