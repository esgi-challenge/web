import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProjectService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/projects',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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

  Future addProject(
    String title,
    double endDate,
    int courseId,
    int classId,
    int documentId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post('$apiUrl/api/projects',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'title': title,
            'endDate': endDate,
            'courseId': courseId,
            'classId': classId,
            'documentId': documentId
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

  Future updateProject(
    int id,
    String title,
    double endDate,
    int courseId,
    int classId,
    int documentId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put('$apiUrl/api/projects/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'title': title,
            'endDate': endDate,
            'courseId': courseId,
            'classId': classId,
            'documentId': documentId
          });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } on DioException {
      return null;
    }
  }

  Future<bool> removeProject(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/projects/$id',
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
