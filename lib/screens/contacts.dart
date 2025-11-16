import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ===============================
// UPDATED DATA MODEL (MATCHES MONGO)
// ===============================
class DepartmentContact {
  final String id;
  final String department;
  final String officerName;
  final String phone;
  final String email;
  final String address;

  DepartmentContact({
    required this.id,
    required this.department,
    required this.officerName,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory DepartmentContact.fromJson(Map<String, dynamic> json) =>
      DepartmentContact(
        id: json['_id'] ?? '',
        department: json['department'] ?? '',
        officerName: json['officerName'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
      );
}

// ===============================
// NETWORK CALL
// ===============================
Future<List<DepartmentContact>> fetchContacts() async {
  final response =
  await http.get(Uri.parse('http://10.0.2.2:5000/api/contacts'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => DepartmentContact.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load contacts");
  }
}

// ===============================
// UI: CONTACT PAGE
// ===============================
class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<DepartmentContact>>(
          future: fetchContacts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final contacts = snapshot.data!;

            return ListView(
              children: [
                SearchBox(),
                SizedBox(height: 16),
                ...contacts.map((contact) => ContactCard(contact: contact)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ===============================
// SEARCH BOX
// ===============================
class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }
}

// ===============================
// CONTACT CARD (NO ISSUES LIST)
// ===============================
class ContactCard extends StatelessWidget {
  final DepartmentContact contact;

  const ContactCard({Key? key, required this.contact}) : super(key: key);

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(contact.department),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Officer: ${contact.officerName}"),
              Text("Contact: ${contact.phone}"),
              Text("Email: ${contact.email}"),
              Text("Address: ${contact.address}"),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        title: Text(
          contact.department,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.officerName),
        trailing: Icon(Icons.chevron_right),
        onTap: () => _showDetails(context),
      ),
    );
  }
}

// ===============================
// MAIN ENTRY
// ===============================
void main() {
  runApp(MaterialApp(home: ContactPage()));
}
