import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:namer_app/buyer_view_page/crop.dart';

class CropService {
  // Base URL for your Django backend
  final String baseUrl = 'http://44.203.237.175:8000';
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

  // Method to fetch available crops
  Future<List<Crop>> getAvailableCrops() async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/buyerview/view_crops/'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Crop> crops = [];
        
        for (var item in data['availableCrops']) {
          crops.add(Crop(
            id: item['id'],
            name: item['cropName'],
            description: item['description'] ?? '',
            price: (item['price'] ?? 0).toDouble(),
            location: item['location'] ?? 'Unknown location',
            category: item['cropName'] ?? 'Uncategorized',
            farmerName: item['farmerName'] ?? 'Unknown Farmer',
            contactNumber: item['contactNumber'] ?? 'Not available',
            harvestDate: DateTime.tryParse(item['harvestDate'] ?? '') ?? DateTime.now(),
            imagePaths: item['imageURLs'] != null && item['imageURLs'].isNotEmpty
                ? List<String>.from(item['imageURLs'])
                : ['lib/assets/default_crop.jpg'],
            rating: 4.0, // Default rating or from backend if available
            quantity: item['quantity'] ?? 0,
            sellerId: item['userId']?? '', // Added quantity from backend
          ));
        }
        return crops;
      } else {
        throw Exception('Failed to load crops: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching crops: $e');
      throw Exception('Failed to load crops: $e');
    }
  }

  // Method to get crop details with farmer information
  Future<Crop> getCropDetails(String cropId) async {
    try {
      final token = await _getAuthToken();

      final response = await http.get(
        Uri.parse('$baseUrl/buyerview/crop-details/$cropId/'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> item = json.decode(response.body);
        print("Seller ID  ggg: ${item['userId']}");
        return Crop(
          id: item['id'],
          name: item['cropName'] ?? 'Unknown crop',
          description: item['description'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
          location: item['location'] ?? 'Unknown location',
          category: item['cropName'] ?? 'Uncategorized',
          farmerName: item['farmerName'] ?? 'Unknown Farmer',
          contactNumber: item['contactNumber'] ?? 'Not available',
          harvestDate: DateTime.tryParse(item['harvestDate'] ?? '') ?? DateTime.now(),
          imagePaths: item['imageURLs'] != null && item['imageURLs'].isNotEmpty
              ? List<String>.from(item['imageURLs'])
              : ['lib/assets/default_crop.jpg'],
          rating: item['rating']?.toDouble() ?? 4.0,
          quantity: item['quantity'] ?? 0, // Added quantity from backend
          sellerId: item['userId'] ?? '',
          
        );
      } else {
        throw Exception('Failed to load crop details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching crop details: $e');
      throw Exception('Failed to load crop details: $e');
    }
  }

  // Method to add a crop to the cart
  Future<void> addToCart(String cropId, int quantity) async {
    try {
      final token = await _getAuthToken();

      final response = await http.post(
        Uri.parse('$baseUrl/buyerview/add-to-cart/'),
        headers: _createHeaders(token),
        body: json.encode({'crop_id': cropId}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 400) {
        // Handle specific error responses
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to add crop to cart');
      } else {
        throw Exception('Failed to add crop to cart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding crop to cart: $e');
      throw Exception('Failed to add crop to cart: $e');
    }
  }
  
  // Method to get user's cart items
  Future<List<Crop>> getCartItems() async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/buyerview/cart-items/'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Crop> cartItems = [];
        
        for (var item in data['cartItems']) {
          cartItems.add(Crop(
            id: item['id'],
            name: item['cropName'] ?? 'Unknown crop',
            description: item['description'] ?? '',
            price: (item['price'] ?? 0).toDouble(),
            location: item['location'] ?? 'Unknown location',
            category: item['cropName'] ?? 'Uncategorized',
            farmerName: item['farmerName'] ?? 'Unknown Farmer',
            contactNumber: item['contactNumber'] ?? 'Not available',
            harvestDate: DateTime.tryParse(item['harvestDate'] ?? '') ?? DateTime.now(),
            imagePaths: item['imageURLs'] != null && item['imageURLs'].isNotEmpty
                ? List<String>.from(item['imageURLs'])
                : ['lib/assets/default_crop.jpg'],
            rating: item['rating']?.toDouble() ?? 4.0,
            quantity: item['quantity'] ?? 0,
            sellerId: item['userId'] ?? '', // Added quantity from backend
          ));
        }
        return cartItems;
      } else {
        throw Exception('Failed to load cart items: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching cart items: $e');
      throw Exception('Failed to load cart items: $e');
    }
  }
  
  // Method to remove a crop from the cart
  Future<void> removeFromCart(String cropId) async {
    try {
      final token = await _getAuthToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/buyerview/remove-from-cart/'),
        headers: _createHeaders(token),
        body: json.encode({'crop_id': cropId}),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to remove crop from cart: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error removing crop from cart: $e');
      throw Exception('Failed to remove crop from cart: $e');
    }
  }
  
  // Method to search for crops
  Future<List<Crop>> searchCrops(String query) async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/buyerview/search-crops/?q=${Uri.encodeComponent(query)}'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Crop> crops = [];
        
        for (var item in data['crops']) {
          crops.add(Crop(
            id: item['id'],
            name: item['cropName'] ?? 'Unknown crop',
            description: item['description'] ?? '',
            price: (item['price'] ?? 0).toDouble(),
            location: item['location'] ?? 'Unknown location',
            category: item['cropName'] ?? 'Uncategorized',
            farmerName: item['farmerName'] ?? 'Unknown Farmer',
            contactNumber: item['contactNumber'] ?? 'Not available',
            harvestDate: DateTime.tryParse(item['harvestDate'] ?? '') ?? DateTime.now(),
            imagePaths: item['imageURLs'] != null && item['imageURLs'].isNotEmpty
                ? List<String>.from(item['imageURLs'])
                : ['lib/assets/default_crop.jpg'],
            rating: item['rating']?.toDouble() ?? 4.0,
            quantity: item['quantity'] ?? 0,
            sellerId: item['userId'], // Added quantity from backend
          ));
        }
        return crops;
      } else {
        throw Exception('Failed to search crops: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error searching crops: $e');
      throw Exception('Failed to search crops: $e');
    }
  }

  // Method to get user crops and stats
  Future<Map<String, dynamic>> getUserCropsAndStats() async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/buyerview/users-crops-details/'),
        headers: _createHeaders(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user crops: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching user crops and stats: $e');
      throw Exception('Failed to load user crops: $e');
    }
  }

// Method to update crop
Future<Map<String, dynamic>> updateCrop(
  String cropId,
  String cropName,
  String description,
  double price,
  String location,
  int quantity,
  String harvestDate,
  List<dynamic> existingImageUrls,
  List<File> newImages,
) async {
  try {
    final token = await _getAuthToken();
    
    // Create multipart request
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/buyerview/update-crop/$cropId/'),
    );
    
    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add text fields
    request.fields['cropName'] = cropName;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['location'] = location;
    request.fields['quantity'] = quantity.toString();
    request.fields['harvestDate'] = harvestDate;
    request.fields['existingImageUrls'] = json.encode(existingImageUrls);
    
    // Add image files if any
    for (var i = 0; i < newImages.length; i++) {
      var file = newImages[i];
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      
      var multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: 'image_$i.jpg',
      );
      
      request.files.add(multipartFile);
    }
    
    // Send request
    var streamedResponse = await request.send().timeout(_timeout);
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update crop: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error updating crop: $e');
    throw Exception('Failed to update crop: $e');
  }
}

// Method to delete crop
Future<void> deleteCrop(String cropId) async {
  try {
    final token = await _getAuthToken();
    
    final response = await http.delete(
      Uri.parse('$baseUrl/buyerview/delete-crop/$cropId/'),
      headers: _createHeaders(token),
    ).timeout(_timeout);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete crop: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error deleting crop: $e');
    throw Exception('Failed to delete crop: $e');
  }
}
}