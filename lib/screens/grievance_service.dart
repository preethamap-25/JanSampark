import 'dart:convert';
import 'package:http/http.dart' as http;

class GrievanceService {
  static const String baseUrl = 'http://your-backend-url/api/grievances';

  // Fetch all grievances
  Future<List<Map<String, dynamic>>> fetchGrievances() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        // Parse the response body into a list of grievances
        List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load grievances');
      }
    } catch (e) {
      throw Exception('Error fetching grievances: $e');
    }
  }
}
