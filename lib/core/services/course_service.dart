import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CourseService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/courses',
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

  Future addCourse(String name, String description, int pathId, int teacherId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post(
        '$apiUrl/api/courses',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'name': name,
          'description': description,
          'pathId': pathId,
          'teacherId': teacherId,
        }
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future updateCourse(int id, String name, String description, int pathId, int teacherId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put(
        '$apiUrl/api/courses/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'name': name,
          'description': description,
          'pathId': pathId,
          'teacherId': teacherId,
        }
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

  Future<bool> removeCourse(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/courses/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException {
      return false;
    }
  }
}