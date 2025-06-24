import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  @override
  _ProviderRegistrationScreenState createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String phone = '';
  String serviceType = 'Plumber';
  String area = '';

  final List<String> serviceOptions = [
    'Plumber',
    'Electrician',
    'House/PG for Rent',
  ];

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('pending_providers').add({
        'name': name,
        'phone': phone,
        'serviceType': serviceType,
        'area': area,
        'submittedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted for review')),
      );
      Navigator.pop(context); // return to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register as Service Provider')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                onChanged: (val) => name = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => phone = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter phone number' : null,
              ),
              DropdownButtonFormField<String>(
                value: serviceType,
                onChanged: (val) => setState(() => serviceType = val!),
                items: serviceOptions.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                decoration: InputDecoration(labelText: 'Service Type'),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Area / City'),
                onChanged: (val) => area = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter area' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
