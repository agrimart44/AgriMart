
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/Cart/CartService.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final List<CartItem> _cartItems = [];
  late CartService _cartService;
  late AuthService _authService;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
    _authService = AuthService();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the Firebase token dynamically using AuthService
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found. Please login again.");
      }

      // Use the token to fetch cart items
      final cartItems = await _cartService.fetchCartItems(firebaseToken);

      setState(() {
        _cartItems.clear();
        _cartItems.addAll(cartItems);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _total => _subtotal;

  void _updateQuantity(String id, int change) async {
    final index = _cartItems.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final newQuantity = _cartItems[index].quantity + change;
    if (newQuantity <= 0) {
      _removeItem(id);
      return;
    }

    setState(() {
      _cartItems[index].quantity = newQuantity;
    });

    try {
      // Get the Firebase token
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found");
      }

      // Update on backend
      await _cartService.updateCartItemQuantity(firebaseToken, id, newQuantity);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update quantity: $e')),
      );
    }
  }

  void _removeItem(String id) async {
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });

    try {
      // Get the Firebase token
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found");
      }

      // Remove from backend
      await _cartService.removeCartItem(firebaseToken, id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove item: $e')),
      );
      _fetchCartItems(); // Refresh to get accurate state
    }
  }

  void _checkout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Checkout"),
        content: const Text("Are you sure you want to place this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Get the Firebase token
        final firebaseToken = await _authService.getStoredFirebaseToken();
        if (firebaseToken == null) {
          throw Exception("No Firebase token found");
        }

        // Process checkout on backend
        final success = await _cartService.checkoutCart(firebaseToken);

        // Close loading dialog
        Navigator.pop(context);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
          setState(() {
            _cartItems.clear();
          });
        } else {
          throw Exception("Checkout failed");
        }
      } catch (e) {
        // Close loading dialog if still showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');

    return SafeArea(
      child: Scaffold(
        appBar: AgriMartAppBar(context, title: "Shopping Cart"),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'lib/assets/first_page_background.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading cart',
                      style: TextStyle(fontSize: 18, color: Colors.red[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchCartItems,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: _cartItems.isEmpty
                    ? _buildEmptyCart()
                    : Column(
                        children: [
                          Expanded(child: _buildCartList(currencyFormat)),
                          _buildOrderSummary(currencyFormat),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to shop page
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(NumberFormat currencyFormat) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.image.isNotEmpty
                      ? Image.network(
                          item.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Seller: ${item.seller}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${currencyFormat.format(item.price)}/${item.unit}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      // Quantity selector
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () => _updateQuantity(item.id, -1),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => _updateQuantity(item.id, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: () => _removeItem(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(NumberFormat currencyFormat) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Subtotal', currencyFormat.format(_subtotal)),
              const Divider(color: Colors.white70),
              _buildSummaryRow('Total', currencyFormat.format(_total),
                  isTotal: true),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
