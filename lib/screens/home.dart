import 'package:flutter/material.dart';
import 'package:jan_sampark/screens/comment.dart';
import 'contacts.dart';
import 'communities.dart';
import 'gpost.dart';
import 'profile.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jan_sampark/services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _localGrievances = [];
  List<Map<String, dynamic>> _grievances = [];

  bool _isLoading = true;

  // Helper to coerce dynamic numeric values safely to int
  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    fetchGrievances();
  }

  Future<void> fetchGrievances() async {
    try {
      final token = await AuthService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('http://localhost:5000/api/grievances'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _grievances = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        print('Failed to load grievances: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching grievances: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GPostPage(
            onGrievanceSubmitted: _addNewGrievance,
          ),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _addNewGrievance(Map<String, dynamic> grievance) {
    setState(() {
      _localGrievances.insert(0, grievance);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDDFE2),
      body: _getSelectedPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          _buildBottomNavigationBarItem(Icons.contact_page, 'Contact', 0),
          _buildBottomNavigationBarItem(Icons.group, 'Communities', 1),
          _buildBottomNavigationBarItem(Icons.home, 'Home', 2),
          _buildBottomNavigationBarItem(Icons.post_add, 'Post', 3),
          _buildBottomNavigationBarItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _getSelectedPage() {
    final List<Widget> _pages = [
      ContactPage(),
      CommunitiesPage(),
      _buildHomePageContent(),
      GPostPage(onGrievanceSubmitted: _addNewGrievance),
      ProfilePage(),
    ];
    return _pages[_selectedIndex];
  }

  Widget _buildHomePageContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'Welcome! User',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'YOUR GRIEVANCES',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            for (var grievance in _localGrievances) _buildGrievanceBox(grievance),
            const SizedBox(height: 20),
            const Text(
              'AROUND YOU',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            for (var grievance in _grievances) _buildGrievanceBoxx(grievance),
          ],
        ),
      ),
    );
  }

  Widget _buildGrievanceBox(Map<String, dynamic> grievance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${grievance['type'] ?? ''}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              grievance['description'] ?? '',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(
                  DateTime.parse(grievance['timestamp'] ?? DateTime.now().toString())),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (grievance['comments'] != null && grievance['comments'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grievance['comments'].map<Widget>((comment) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      comment,
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrievanceBoxx(Map<String, dynamic> grievance) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grievance['title'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Upvote Button
                  IconButton(
                    icon: Icon(
                      (grievance['hasUpvoted'] == true)
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined,
                      color: (grievance['hasUpvoted'] == true) ? Colors.blue : null,
                    ),
                    onPressed: () {
                      setState(() {
            // Normalize values
            int up = _asInt(grievance['upvotes']);
            int down = _asInt(grievance['downvotes']);
                        bool hasUp = grievance['hasUpvoted'] == true;
                        bool hasDown = grievance['hasDownvoted'] == true;

                        if (hasUp) {
                          // remove upvote
                          up = (up > 0) ? up - 1 : 0;
                          hasUp = false;
                        } else {
                          // add upvote
                          up = up + 1;
                          hasUp = true;
                          // if previously downvoted, remove that downvote
                          if (hasDown) {
                            down = (down > 0) ? down - 1 : 0;
                            hasDown = false;
                          }
                        }

                        grievance['upvotes'] = up;
                        grievance['downvotes'] = down;
                        grievance['hasUpvoted'] = hasUp;
                        grievance['hasDownvoted'] = hasDown;
                      });
                    },
                  ),
                  Text((grievance['upvotes'] ?? 0).toString()),

                  // Downvote Button
                  IconButton(
                    icon: Icon(
                      (grievance['hasDownvoted'] == true)
                          ? Icons.thumb_down
                          : Icons.thumb_down_alt_outlined,
                      color: (grievance['hasDownvoted'] == true) ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() {
            int up = _asInt(grievance['upvotes']);
            int down = _asInt(grievance['downvotes']);
                        bool hasUp = grievance['hasUpvoted'] == true;
                        bool hasDown = grievance['hasDownvoted'] == true;

                        if (hasDown) {
                          // remove downvote
                          down = (down > 0) ? down - 1 : 0;
                          hasDown = false;
                        } else {
                          // add downvote
                          down = down + 1;
                          hasDown = true;
                          // if previously upvoted, remove that upvote
                          if (hasUp) {
                            up = (up > 0) ? up - 1 : 0;
                            hasUp = false;
                          }
                        }

                        grievance['upvotes'] = up;
                        grievance['downvotes'] = down;
                        grievance['hasUpvoted'] = hasUp;
                        grievance['hasDownvoted'] = hasDown;
                      });
                    },
                  ),
                  Text((grievance['downvotes'] ?? 0).toString()),
                ],
              ),
              IconButton(
                icon: Icon(Icons.comment_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentPage(grievance: grievance),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (grievance['comments'] != null && grievance['comments'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: grievance['comments'].map<Widget>((comment) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    comment,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    ),
  );
}


  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _selectedIndex == index
          ? Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                ),
                Icon(icon, color: Colors.blue),
              ],
            )
          : Icon(icon),
      label: label,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
