import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PathService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/paths',
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

  Future addPath(String shortName, String longName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post(
        '$apiUrl/api/paths',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'shortName': shortName,
          'longName': longName,
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

  Future updatePath(int id, String shortName, String longName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put(
        '$apiUrl/api/paths/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'shortName': shortName,
          'longName': longName,
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

  Future<bool> removePath(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/paths/$id',
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