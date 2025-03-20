import 'dart:convert';
import 'package:http/http.dart' as http;

class CropService {
  // Base URL for your API
  final String baseUrl = 'http://44.203.237.175:8000/api';

  // Method to upload crop details
  Future<Map<String, dynamic>> uploadCrop({
    required String cropName,
    required String description,
    required double price,
    required String location,
    double? latitude,
    double? longitude,
    required int quantity,
    required String harvestDate,
    required List<String> imagePaths,
    required String firebaseToken,
  }) async {
    try {
      print("Starting crop upload process");
      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/crops/upload_crop/'),
      );

      // Add authorization header with Firebase token
      request.headers.addAll({
        'Authorization': 'Bearer $firebaseToken',
      });

      // Add text fields
      request.fields['cropName'] = cropName;
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['location'] = location;

      // Add latitude and longitude if available
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      request.fields['quantity'] = quantity.toString();

      // Format date to YYYY-MM-DD
      final parts = harvestDate.split('/');
      if (parts.length == 3) {
        // Convert from DD/MM/YYYY to YYYY-MM-DD
        request.fields['harvestDate'] = '${parts[2]}-${parts[1]}-${parts[0]}';
      } else {
        request.fields['harvestDate'] = harvestDate;
      }

      // Add image files
      for (String path in imagePaths) {
        var file = await http.MultipartFile.fromPath('images', path);
        request.files.add(file);
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Parse response
      Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print("Crop uploaded successfully");
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        print("Failed to upload crop: ${responseData['error']}");
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to upload crop',
        };
      }
    } catch (e) {
      print("Exception during crop upload: $e");
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Method to get all crops
  Future<Map<String, dynamic>> getAllCrops({
    required String firebaseToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crops/get_all_crops/'),
        headers: {
          'Authorization': 'Bearer $firebaseToken',
        },
      );

      Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['crops'],
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to fetch crops',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Method to get user's crops
  Future<Map<String, dynamic>> getUserCrops({
    required String firebaseToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/crops/get_user_crops/'),
        headers: {
          'Authorization': 'Bearer $firebaseToken',
        },
      );

      Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['crops'],
        };
      } else {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Failed to fetch user crops',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
