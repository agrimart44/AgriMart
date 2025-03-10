import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    
    if (googleUser == null) {
      // User canceled the sign-in process
      return null;
    }
    
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Sign in to Firebase with the credential
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    
    // Navigate to the home screen or any other screen after successful login
    Navigator.pushReplacementNamed(context, '/home');
    
    // Return the userCredential
    return userCredential;
  } catch (e) {
    // Handle errors
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
    return null;
  }
}