import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _authKey = 'kAuth';

  static String? jwt;

  static Future<String?> init() async {
    final prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString(_authKey);
    return jwt;
  }

  static Future<String?> saveJwt(String jwt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jwt);
    return jwt;
  }
}