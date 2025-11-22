import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Validate if student_id exists in database
  Future<Map<String, dynamic>> validateStudent(String studentId) async {
    try {
      // Use 10.0.2.2 for Android emulator to access host machine's localhost
      final url = 'http://10.0.2.2:3000/student/$studentId';
      print('🌐 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Try to parse as JSON
        try {
          final result = jsonDecode(response.body);
          // Transform the response to match the expected format
          return {
            'valid': true,
            'student': result,
          };
        } catch (e) {
          // If JSON parsing fails, it's probably an error message
          throw Exception('API returned non-JSON response: ${response.body}');
        }
      } else if (response.statusCode == 404) {
        // Student not found
        return {
          'valid': false,
          'message': 'Student ID not found',
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Register student with email and password
  Future<Map<String, dynamic>> registerStudent(
      String studentId, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/student/create'),
        headers: _headers,
        body: jsonEncode({
          'student_id': studentId,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Test connection method
  Future<void> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api.php'));
      print('Connection test - Status: ${response.statusCode}');
      print('Connection test - Body: ${response.body}');
    } catch (e) {
      print('Connection test failed: $e');
    }
  }
}