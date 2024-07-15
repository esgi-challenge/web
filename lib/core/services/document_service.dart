import 'dart:io';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DocumentService {
  String? apiUrl = dotenv.env['API_URL'];
  final dio = Dio();

  Future<List<dynamic>?> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.get(
        '$apiUrl/api/documents',
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

  Future addDocument(String name, int? courseId, Uint8List documentBytes, String documentName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'courseId': courseId,
        'file': MultipartFile.fromBytes(documentBytes, filename: documentName),
      });

      final response = await dio.post(
        '$apiUrl/api/documents',
        options: Options(
          headers: {'Authorization': 'Bearer $token'}
        ),
        data: formData
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

  Future<bool> removeDocument(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('kAuth');
    try {
      final response = await dio.delete(
        '$apiUrl/api/documents/$id',
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