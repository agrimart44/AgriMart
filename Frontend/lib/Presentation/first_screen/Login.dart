import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:namer_app/Presentation/sginIn/face_book_sign_in.dart';
import 'package:namer_app/Presentation/sginIn/google_sign_in.dart';
import 'package:namer_app/farmer_view_page/farmer_view.dart';
// Add this import
import 'package:namer_app/chatScreen/chat_service.dart'; // Adjust path as needed

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
  final ChatService _chatService = ChatService('xqww9xknukff'); // Replace with your actual Stream API key

  // Login function
  void login(BuildContext context) async {
    final authService = AuthService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
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
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'lib/assets/first_page_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Apply BackdropFilter
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3), //  transparent overlay
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height:5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Text(
                              "Login to Agri Mart",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Email Field
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.5),
                                prefixIcon: const Icon(Icons.email, color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.black.withOpacity(0.5),
                                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                            ),
                            const SizedBox(height: 20),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => login(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff39B54A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: forgotLink,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Divider with "Or Login With"
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "Or Login With",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withOpacity(0.5),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Social Login Buttons (Facebook, Google, Apple)
                            Column(
                              children: [
                                SignInButton(
                                  Buttons.Facebook,
                                  onPressed: () async {
                                    UserCredential? credential = await signInWithFacebook(context);
                                    if (credential != null) {
                                      handleSuccessfulAuth(credential, context);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                const SizedBox(height: 10),
                                SignInButton(
                                  Buttons.Google,
                                  onPressed: () async {
                                    UserCredential? credential = await signInWithGoogle(context);
                                    if (credential != null) {
                                      handleSuccessfulAuth(credential, context);
                                    }
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}