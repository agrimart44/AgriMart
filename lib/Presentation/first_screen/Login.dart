import 'dart:ui'; // Import the dart:ui library for BackdropFilter

import 'package:flutter/material.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers for email and password fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Login function
  void login(BuildContext context) async {
  final authService = AuthService();

  // Validate fields
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Please fill in all fields.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            
            child: Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Try login
  try {
    await authService.signinWithEmailpassword(
      _emailController.text,
      _passwordController.text,
    );
    // Navigate to the next screen on success
    Navigator.pushReplacementNamed(context, '/home'); // Replace with your route
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

  //Forgot Password function
  forgotLink(){

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        leading: SizedBox(child: Icon(Icons.arrow_back_ios), width: 15, height: 15), 
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
          // Apply BackdropFilter (blur effect) to the background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: const Color.fromARGB(255, 150, 141, 141).withOpacity(0.2), // Add a transparent grey overlay
              ),
            ),
          ),

          // "Login to Agri Mart" text
          Positioned(
            top: 100, 
            left: 20,
            right: 20,
            child: Text(
              "Login to Agri Mart",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xff3D3D3D), 
              ),
              textAlign: TextAlign.center,
            ),
          ),





          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xff3D3D3D),
                    
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0xff3D3D3D),
                    
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                // Login Button
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement Login Functionality here
                        login(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff39B54A), 
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Login', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight, // Align the text to the right side
                  child: TextButton(
                    onPressed: () {
                      // Implement Forgot Password functionality here
                      forgotLink();
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black, // Set text color to black
                        fontSize: 18, // Set font size to 18
                        fontWeight: FontWeight.w600, // Set font weight to 600
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Divider with "Or Login With"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    Container(
                      child: Text(
                        "Or Login With",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Social Login Buttons (Facebook, Google, Apple)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.facebook),
                      onPressed: () {
                        // Implement Facebook login functionality here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.g_mobiledata_rounded),
                      onPressed: () {
                        // Implement Google login functionality here
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.apple),
                      onPressed: () {
                        // Implement Apple login functionality here
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
