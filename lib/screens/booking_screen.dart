import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  final String serviceName;

  BookingScreen({required this.serviceName});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String paymentMethod = 'Cash';

  void selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void confirmBooking() {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select date and time.'),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Booking Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Service: ${widget.serviceName}'),
            Text('Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
            Text('Time: ${selectedTime!.format(context)}'),
            Text('Payment: $paymentMethod'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.serviceName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              title: Text(selectedDate == null
                  ? 'Choose Date'
                  : 'Date: ${selectedDate!.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: selectDate,
            ),
            ListTile(
              title: Text(selectedTime == null
                  ? 'Choose Time'
                  : 'Time: ${selectedTime!.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: selectTime,
            ),
            ListTile(
              title: Text('Payment Method'),
              subtitle: Row(
                children: [
                  Radio<String>(
                    value: 'Cash',
                    groupValue: paymentMethod,
                    onChanged: (val) => setState(() => paymentMethod = val!),
                  ),
                  Text('Cash'),
                  Radio<String>(
                    value: 'Online',
                    groupValue: paymentMethod,
                    onChanged: (val) => setState(() => paymentMethod = val!),
                  ),
                  Text('Online'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmBooking,
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
