import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String apiUrl = 'http://44.203.237.175:8000/cart/getItems/'; // Backend URL
  
  // Fetch cart items from the backend
  Future<List<CartItem>> fetchCartItems(String firebaseToken) async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': firebaseToken, // Passing Firebase token
      },
    );
    
    if (response.statusCode == 200) {
      
      print('Cart items loaded successfully');
      print(response.body);
      print(firebaseToken);
      final List<dynamic> data = json.decode(response.body)['availableCrops'];
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart items: ${response.reasonPhrase}');
    }
  }

  // Update cart item quantity on the backend
  Future<bool> updateCartItemQuantity(String firebaseToken, String itemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl$itemId/quantity'),
        headers: {
          'Authorization': firebaseToken,
          'Content-Type': 'application/json',
        },
        body: json.encode({'quantity': quantity}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  // Remove item from cart on the backend
  Future<bool> removeCartItem(String firebaseToken, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl$itemId'),
        headers: {
          'Authorization': firebaseToken,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing item: $e');
      return false;
    }
  }

  // Checkout the cart
  Future<bool> checkoutCart(String firebaseToken) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/checkout'),
        headers: {
          'Authorization': firebaseToken,
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error during checkout: $e');
      return false;
    }
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String image;
  final String seller;
  
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.seller,
  });
  
  // Factory method to create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'] ?? 1, 
      image: json['imageURL'] ?? '',
      seller: json['farmer'] ?? 'Unknown',
    );
  }
}