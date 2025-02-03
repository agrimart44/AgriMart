import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';  // Import the chat screen after successful login

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;  // To show loading indicator

  // Sign in anonymously
  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _auth.signInAnonymously();  // Sign in anonymously using Firebase Auth
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),  // Navigate to Chat screen
      );
    } catch (e) {
      // Handle any error that occurs during sign-in
      print('Error signing in: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()  // Show loading indicator during sign-in
            : ElevatedButton(
                onPressed: _signInAnonymously,
                child: Text('Sign In Anonymously'),
              ),
      ),
    );
  }
}
