import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Data model
class DepartmentContact {
  final String title;
  final List<String> issues;
  final String contactNumber;
  final String email;
  final String address;
  final String officerName;

  DepartmentContact({
    required this.title,
    required this.issues,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.officerName,
  });

  factory DepartmentContact.fromJson(Map<String, dynamic> json) =>
      DepartmentContact(
        title: json['title'],
        issues: List<String>.from(json['issues']),
        contactNumber: json['contactNumber'],
        email: json['email'],
        address: json['address'],
        officerName: json['officerName'],
      );
}

// Network fetch for contacts (replace with your API endpoint)
Future<List<DepartmentContact>> fetchContacts() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/contacts'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) => DepartmentContact.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load contacts");
  }
}

// Main Contact Page (styling unchanged)
class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Page'),
      ),
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
                ...contacts.map((dept) => ContactCard(
                  title: dept.title,
                  issues: dept.issues,
                  contactNumber: dept.contactNumber,
                  email: dept.email,
                  address: dept.address,
                  officerName: dept.officerName,
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}

// SearchBox (unchanged)
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

// ContactCard (to show all details; styling unchanged)
class ContactCard extends StatefulWidget {
  final String title;
  final List<String> issues;
  final String contactNumber;
  final String email;
  final String address;
  final String officerName;

  const ContactCard({
    Key? key,
    required this.title,
    required this.issues,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.officerName,
  }) : super(key: key);

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  bool _isExpanded = false;

  void _showContactDetails(BuildContext context, String issue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(issue),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Department: ${widget.title}'),
              Text('Officer: ${widget.officerName}'),
              Text('Contact: ${widget.contactNumber}'),
              Text('Email: ${widget.email}'),
              Text('Address: ${widget.address}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2.0,
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: widget.issues
            .map((issue) => ListTile(
                  title: Text(issue),
                  leading: Icon(Icons.chevron_right),
                  onTap: () {
                    _showContactDetails(context, issue);
                  },
                ))
            .toList(),
      ),
    );
  }
}

// Main entry (unchanged)
void main() {
  runApp(MaterialApp(
    home: ContactPage(),
  ));
}
