import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StudentService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schools/users/student',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 409) {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future addStudent(
      String email, String firstname, String lastname, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post('$apiUrl/api/schools/add/student',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'email': email,
            'firstname': firstname,
            'lastname': lastname,
            'password': password
          });

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 409) {
        throw Exception('Email is already used');
      }
      return null;
    }
  }

  Future inviteUser(String email, String firstname, String lastname) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post('$apiUrl/api/schools/invite',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'email': email,
            'firstname': firstname,
            'lastname': lastname,
            'type': 'STUDENT'
          });

      if (response.statusCode == 201) {
        return response.data;
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future updateStudent(
      int id, String email, String firstname, String lastname) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put('$apiUrl/api/schools/update/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {'email': email, 'firstname': firstname, 'lastname': lastname});

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future<bool> removeStudent(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/schools/remove/student/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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
