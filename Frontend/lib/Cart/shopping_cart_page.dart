import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/Cart/CartService.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:http/http.dart' as http;


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
  bool _processingCheckout = false;

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
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found. Please login again.");
      }

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

      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  double get _deliveryFee => _subtotal > 500 ? 0 : 50;
  
  double get _total => _subtotal + _deliveryFee;

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
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found");
      }

      await _cartService.updateCartItemQuantity(firebaseToken, id, newQuantity);
    } catch (e) {
      _showSnackBar('Failed to update quantity: $e', isError: true);
    }
  }

  void _removeItem(String id) async {
    final removedItem = _cartItems.firstWhere((item) => item.id == id);
    final removedIndex = _cartItems.indexWhere((item) => item.id == id);
    
    setState(() {
      _cartItems.removeWhere((item) => item.id == id);
    });

    _showSnackBar(
      '${removedItem.name} removed from cart',
      isError: false,
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () async {
          setState(() {
            if (removedIndex < _cartItems.length) {
              _cartItems.insert(removedIndex, removedItem);
            } else {
              _cartItems.add(removedItem);
            }
          });
          
          try {
            final firebaseToken = await _authService.getStoredFirebaseToken();
            if (firebaseToken == null) {
              throw Exception("No Firebase token found");
            }
            // Re-add item to backend if undo is pressed
            // This depends on your backend implementation
          } catch (e) {
            _showSnackBar('Failed to restore item: $e', isError: true);
          }
        },
      ),
    );

    try {
      final firebaseToken = await _authService.getStoredFirebaseToken();
      if (firebaseToken == null) {
        throw Exception("No Firebase token found");
      }

      await _cartService.removeCartItem(firebaseToken, id);
    } catch (e) {
      _showSnackBar('Failed to remove item from server: $e', isError: true);
      _fetchCartItems(); // Refresh to get accurate state
    }
  }

  void _showSnackBar(String message, {bool isError = false, SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: action,
      ),
    );
  }

  void _checkout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to place this order?"),
            const SizedBox(height: 16),
            _buildCheckoutSummary(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _processingCheckout = true;
      });
      
      try {
        final firebaseToken = await _authService.getStoredFirebaseToken();
        if (firebaseToken == null) {
          throw Exception("No Firebase token found");
        }

        final success = await _cartService.checkoutCart(firebaseToken);

        setState(() {
          _processingCheckout = false;
        });

        if (success) {
          _showOrderSuccess();
          setState(() {
            _cartItems.clear();
          });
        } else {
          throw Exception("Checkout failed");
        }
      } catch (e) {
        setState(() {
          _processingCheckout = false;
        });
        _showSnackBar('Checkout failed: $e', isError: true);
      }
    }
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                "Order Placed Successfully!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Your order has been received and is being processed.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Return to product listing
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CONTINUE SHOPPING"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSummary() {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_cartItems.length} items', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(currencyFormat.format(_total), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ');

    return SafeArea(
      child: Scaffold(
        appBar: AgriMartAppBar(context, title: "My Cart"),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background image with overlay
            Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'lib/assets/first_page_background.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            else if (_errorMessage != null)
              _buildErrorState()
            else
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: _cartItems.isEmpty
                    ? _buildEmptyCart()
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_cartItems.length} items',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),

                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      final firebaseToken = await _authService.getStoredFirebaseToken();
                                      if (firebaseToken == null) {
                                        throw Exception("No Firebase token found. Please login again.");
                                      }

                                      final url = Uri.parse('http://192.168.43.27:8000/cart/clearCart/');
                                      final response = await http.post(
                                        url,
                                        headers: {
                                          'Authorization': firebaseToken,
                                        },
                                      );

                                      if (response.statusCode == 200) {
                                        setState(() {
                                          _cartItems.clear(); // Clear cart items from UI
                                        });
                                        _showSnackBar('Cart cleared successfully', isError: false);
                                      } else {
                                        throw Exception('Failed to clear cart: ${response.statusCode}');
                                      }
                                    } catch (e) {
                                      _showSnackBar('Error clearing cart: $e', isError: true);
                                    }
                                  },
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  label: const Text('Clear All'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Expanded(child: _buildCartList()),
                          if (_cartItems.isNotEmpty) _buildOrderSummary(currencyFormat),
                        ],
                      ),
              ),

            // Loading overlay for checkout
            if (_processingCheckout)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 16),
                            Text("Processing your order...", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 20, color: Colors.red[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load your cart',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchCartItems,
              icon: const Icon(Icons.refresh),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildEmptyCart() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/empty_cart.png', // Replace with your empty cart image
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Looks like you haven\'t added any items to your cart yet.',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to shop page
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.shop),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: const Text('Browse Products'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Dismissible(
          key: Key(item.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            _removeItem(item.id);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product image with animated container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.image.isNotEmpty
                          ? Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.store_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.seller,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              NumberFormat.currency(symbol: 'Rs. ').format(item.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '/${item.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Quantity selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrease button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _updateQuantity(item.id, -1),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.remove, size: 16),
                                  ),
                                ),
                              ),
                              
                              // Quantity display
                              Container(
                                constraints: const BoxConstraints(minWidth: 40),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              // Increase button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _updateQuantity(item.id, 1),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.add, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(NumberFormat currencyFormat) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
        
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormat.format(_total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
    );
  }
}