import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schedules',
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

  Future addSchedule(
      int time, int duration, int courseId, int campusId, int classId, bool qrCodeEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.post('$apiUrl/api/schedules',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'time': time,
            'duration': duration,
            'courseId': courseId,
            'campusId': campusId,
            'classId': classId,
            'qrCodeEnabled': qrCodeEnabled,
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

  Future updateSchedule(int id, int time, int duration, int courseId,
      int campusId, int classId, bool qrCodeEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.put('$apiUrl/api/schedules/$id',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
          data: {
            'time': time,
            'duration': duration,
            'courseId': courseId,
            'campusId': campusId,
            'classId': classId,
            'qrCodeEnabled': qrCodeEnabled
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

  Future<bool> removeSchedule(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/schedules/$id',
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

  Future<String?> getCode(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schedules/$id/code',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['code'];
      }

      return null;
    } on DioException {
      return null;
    }
  }

  Future getSignatures(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/schedules/$id/students',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }

      return null;
    } on DioException {
      return null;
    }
  }

  Future sign(int scheduleId, int userId, String code) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      await dio.post(
        '$apiUrl/api/schedules/$scheduleId/sign',
        data: {"code": code, "userId": userId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return null;
    } on DioException {
      return null;
    }
  }
}
