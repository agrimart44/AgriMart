import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // If using Firebase

void signInWithFacebook(BuildContext context) async {
  try {
    // Trigger Facebook login
    final LoginResult result = await FacebookAuth.instance.login();

    // Check if login was successful
    if (result.status == LoginStatus.success) {
      // Get the access token correctly
      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;

      if (accessToken != null) {
        // Use the access token to authenticate with Firebase (if using Firebase)
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString); // Use tokenString
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // If successful, navigate to the home screen or perform other actions
        Navigator.pushReplacementNamed(context, '/home'); // Replace with your route
      } else {
        // Handle missing access token
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Could not retrieve access token.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else if (result.status == LoginStatus.cancelled) {
      // Handle the case when the user cancels the login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Cancelled'),
          content: const Text('You cancelled the login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Handle other errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(result.message ?? 'An error occurred during Facebook login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Handle any other errors
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