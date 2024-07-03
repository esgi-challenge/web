import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TeacherService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getTeachers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schools/users/teacher',
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

  Future addTeacher(String email, String firstname, String lastname, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post(
        '$apiUrl/api/schools/add/teacher',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'email': email,
          'firstname': firstname,
          'lastname': lastname,
          'password': password
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

  Future updateTeacher(int id, String email, String firstname, String lastname) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put(
        '$apiUrl/api/schools/update/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'email': email,
          'firstname': firstname,
          'lastname': lastname
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

  Future<bool> removeTeacher(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/schools/remove/teacher/$id',
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