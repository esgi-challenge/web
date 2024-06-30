import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentService {
  static const _baseUrl = 'http://localhost:8080/api/schools';

  Future<List<dynamic>?> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    final decodedToken = JwtDecoder.decode(token!);
    final schoolId = decodedToken['user']['schoolId'];
    final response = await http.get(
      Uri.parse('$_baseUrl/$schoolId/students'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}