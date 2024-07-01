import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SchoolService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<Map<String, dynamic>?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schools',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future<void> createSchool(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try{
      final response = await dio.post(
        '$apiUrl/api/schools',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: {'name': name},
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create school');
      }
    } on DioException {
      throw Exception('Failed to create school');
    }
  }
}