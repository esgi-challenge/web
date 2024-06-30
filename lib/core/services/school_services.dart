import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SchoolService {
  static const _baseUrl = 'http://localhost:8080/api/schools';

  Future<Map<String, dynamic>?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      return decodedResponse[0];
    } else {
      return null;
    }
  }

  Future<void> createSchool(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create school');
    }
  }
}