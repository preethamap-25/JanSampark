import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart'; // <-- to get JWT
import '../services/api_service.dart';  // <-- to use authenticated API calls

class GPostPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onGrievanceSubmitted;

  GPostPage({required this.onGrievanceSubmitted});

  @override
  _GPostPageState createState() => _GPostPageState();
}

class _GPostPageState extends State<GPostPage> {
  String? _selectedGrievanceType;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedCategory;
  String? _selectedConcern;
  TextEditingController _grievanceController = TextEditingController();

  List<String> grievanceTypes = [
    'Complaint',
    'Suggestion',
    'Seeking Guidance/Info'
  ];

  List<String> states = [
    'Andhra Pradesh',
    'Maharashtra',
    'Delhi',
    'Tamil Nadu',
    'Telangana',
    'West Bengal',
    'Karnataka'
  ];

  List<String> districts = [
    'Hyderabad',
    'Vizag',
    'Chennai',
    'Mumbai',
    'Kolkata',
    'Delhi',
    'Bengaluru'
  ];

  List<String> categories = [
    'Public Services',
    'Infrastructure',
    'Healthcare',
    'Education',
    'Environment'
  ];

  List<String> concerns = [
    'Road Maintenance',
    'Water Supply',
    'Hospital Services',
    'School Facilities',
    'Pollution'
  ];

  File? _selectedPDF;
  List<File> _selectedImages = [];

  bool _isSubmitting = false;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedPDF = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> _submitGrievance() async {
    if (_selectedGrievanceType == null ||
        _selectedState == null ||
        _selectedDistrict == null ||
        _selectedCategory == null ||
        _selectedConcern == null ||
        _grievanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You must be logged in to submit a grievance.')),
        );
        return;
      }

      // Build form data (multipart request)
      var uri = Uri.parse('http://10.0.2.2:5000/api/grievances');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = _selectedGrievanceType!;
      request.fields['description'] = _grievanceController.text;
      request.fields['category'] = _selectedCategory!;
      request.fields['location'] = '$_selectedDistrict, $_selectedState';

      // Attach images
      for (var img in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath('media', img.path));
      }

      // Attach PDF (optional)
      if (_selectedPDF != null) {
        request.files.add(await http.MultipartFile.fromPath('media', _selectedPDF!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final grievance = json.decode(response.body);
        widget.onGrievanceSubmitted(grievance);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Success'),
            content: Text('Your grievance has been submitted successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );

        _grievanceController.clear();
        setState(() {
          _selectedImages.clear();
          _selectedPDF = null;
        });
      } else {
        print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit grievance. Try again.')),
        );
      }
    } catch (e) {
      print('Error submitting grievance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDDFE2),
      appBar: AppBar(
        title: Text('Grievance Upload'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownField('Type Of Grievance', _selectedGrievanceType, grievanceTypes, (v) => setState(() => _selectedGrievanceType = v)),
              _buildDropdownField('State', _selectedState, states, (v) => setState(() => _selectedState = v)),
              _buildDropdownField('District', _selectedDistrict, districts, (v) => setState(() => _selectedDistrict = v)),
              _buildDropdownField('Grievance Category/Ministry', _selectedCategory, categories, (v) => setState(() => _selectedCategory = v)),
              _buildDropdownField('Grievance Concerns to?', _selectedConcern, concerns, (v) => setState(() => _selectedConcern = v)),
              _buildTextField(),
              _buildImagePicker(),
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitGrievance,
                  child: _isSubmitting
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('SUBMIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String title, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('Select $title'),
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type Your Grievance Here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: _grievanceController,
          maxLines: 6,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(),
            hintText: 'Enter your grievance details',
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Images here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.image),
          label: Text('Upload Images'),
        ),
        if (_selectedImages.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _selectedImages.map((image) {
              return Image.file(image, width: 100, height: 100, fit: BoxFit.cover);
            }).toList(),
          ),
        SizedBox(height: 16),
      ],
    );
  }
}
