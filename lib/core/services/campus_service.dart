import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CampusService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getCampus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/campus',
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

  Future addCampus(double latitude, double longitude, String location, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post(
        '$apiUrl/api/campus',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
          'name': name,
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

  Future updateCampus(int id, double latitude, double longitude, String location, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put(
        '$apiUrl/api/campus/$id',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
          'name': name,
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

  Future<bool> removeCampus(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/campus/$id',
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