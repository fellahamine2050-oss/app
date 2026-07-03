import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://YOUR_SERVER_URL:5000/api';
  // للتجربة المحلية: http://10.0.2.2:5000/api (Android Emulator)
  // للإنتاج: ضع رابط سيرفرك (Heroku, Railway, etc.)

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // === AUTH ===
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveToken(data['token']);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return data;
    }
    throw Exception(data['message']);
  }

  // === SUBSCRIPTIONS ===
  static Future<List<dynamic>> getSubscriptions() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/subscriptions'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load subscriptions');
  }

  static Future<Map<String, dynamic>> addSubscription(Map<String, dynamic> subscription) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions'),
      headers: headers,
      body: jsonEncode(subscription),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to add subscription');
  }

  static Future<void> deleteSubscription(String id) async {
    final headers = await _getHeaders();
    await http.delete(Uri.parse('$baseUrl/subscriptions/$id'), headers: headers);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/subscriptions/stats'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load stats');
  }
}
