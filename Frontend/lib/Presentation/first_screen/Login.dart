
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:namer_app/Presentation/registerpage/registerpage.dart';
import 'package:namer_app/farmer_view_page/farmer_view.dart';

import '../../ChatScreen/chat_service.dart' show ChatService;




class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Add ChatService instance
  final ChatService _chatService = ChatService('xqww9xknukff');

  // Login function
  void login(BuildContext context) async {
    final authService = AuthService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
        ),
      ),
    );

    // Validate fields
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Close loading indicator
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Try login
    try {
      UserCredential userCredential = await authService.signinWithEmailpassword(
        _emailController.text,
        _passwordController.text,
      );

      String userId = userCredential.user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      // Send user ID to backend to retrieve the Stream JWT token
      final streamToken = await authService.getStreamToken(userId);
      
      // Connect to Stream chat using the token
      await _chatService.connectUser(userId, streamToken);
      print("User connected to Stream from login");

      // Close loading indicator
      Navigator.pop(context);

      // Navigate to the next screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerView()),
      );
    } catch (e) {
      // Close loading indicator
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Also update the social sign-in methods to connect to Stream
  void handleSuccessfulAuth(UserCredential userCredential, BuildContext context) async {
    try {
      String userId = userCredential.user?.uid ?? '';
      
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }
      
      final authService = AuthService();
      final streamToken = await authService.getStreamToken(userId);
      
      // Connect to Stream chat using the token
      await _chatService.connectUser(userId, streamToken);
      print("User connected to Stream from social login");
      
      // Navigate to the next screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerView()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text("Error connecting to chat: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Forgot Password function
  void forgotLink() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 25, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Logo container
                      Container(
                        padding: const EdgeInsets.all(10), 
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white, 
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2), 
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4), 
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/assets/AgriMart_UI.jpg', 
                            fit: BoxFit.contain,
                            width: 80, 
                            height: 80,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        "Welcome to AgriMart",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        "Login to Continue",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 40),

                      // Login card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Email Field
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                hintText: "Enter your email",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.green[700]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: TextStyle(color: Colors.grey[800], fontSize: 16),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            
                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                hintText: "Enter your password",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                floatingLabelBehavior: FloatingLabelBehavior.auto,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.green[700]!),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              style: TextStyle(color: Colors.grey[800], fontSize: 16),
                              obscureText: true,
                            ),
                            
                            const SizedBox(height: 24),

                            // Login Button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade500,
                                    Colors.green.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.3),
                                    spreadRadius: 0,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => login(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sign Up prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green[700],
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}