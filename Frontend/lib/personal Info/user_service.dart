import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';

class UserService {
  // Base URL for your Django backend
  final String baseUrl = 'http://54.205.26.198:8000';
  final AuthService _authService = AuthService();
  
  // Timeout duration for API requests
  static const Duration _timeout = Duration(seconds: 15);

  // Helper method to get authentication token
  Future<String> _getAuthToken() async {
    final token = await _authService.getStoredFirebaseToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return token;
  }

  // Helper method to create request headers
  Map<String, String> _createHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Method to fetch user details
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_details/'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return userData;
      } else {
        throw Exception('Failed to load user details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      throw Exception('Failed to load user details: $e');
    }
  }

  // Method to update user details
  Future<Map<String, dynamic>> updateUserDetails({
    required String name,
    required String phoneNumber,
    required String occupation,
    required String location,
  }) async {
    try {
      final token = await _getAuthToken();

      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone_number': phoneNumber,
        'occupation': occupation,
        'location': location,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/update_user_details/'),
        headers: _createHeaders(token),
        body: json.encode(requestBody),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating user details: $e');
      throw Exception('Failed to update user details: $e');
    }
  }

  // Method to check if user is a farmer or buyer
  Future<bool> isFarmer() async {
    try {
      final userData = await getUserDetails();
      return userData['occupation'] == 'Farmer';
    } catch (e) {
      print('Error checking user role: $e');
      throw Exception('Failed to check user role: $e');
    }
  }

  // Method to get user's cart
  Future<List<String>> getUserCart() async {
    try {
      final userData = await getUserDetails();
      if (userData.containsKey('cart') && userData['cart'] is List) {
        return List<String>.from(userData['cart']);
      }
      return [];
    } catch (e) {
      print('Error fetching user cart: $e');
      throw Exception('Failed to load user cart: $e');
    }
  }
}