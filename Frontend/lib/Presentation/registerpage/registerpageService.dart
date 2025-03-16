import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationService {
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String occupation,
    required String location,
  }) async {
    final url = Uri.parse('http://192.168.43.27:8000/api/register/');

    try {
      // Create request body for debugging
      final requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'phone_number': phoneNumber,
        'occupation': occupation,
        'location': location,
      };

      // Print request body for debugging
      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Print response status and body for debugging
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // Safely parse the response body
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        print('Error decoding response: $e');
        print('Raw response: ${response.body}');
        responseData = {'error': 'Invalid response format from server'};
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
        };
      } else {
        // Handle error response based on actual format
        String errorMessage;
        if (responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'].toString();
        } else {
          errorMessage = 'Registration failed: ${response.body}';
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (error) {
      // Enhanced error logging
      print('Registration Error: $error');
      return {
        'success': false,
        'message': 'Network error: ${error.toString()}',
      };
    }
  }
}
