import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithFacebook(BuildContext context) async {
  try {
    // Trigger Facebook login
    final LoginResult result = await FacebookAuth.instance.login();

    // Check if login was successful
    if (result.status == LoginStatus.success) {
      // Get the access token correctly
      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;

      if (accessToken != null) {
        // Use the access token to authenticate with Firebase
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
        
        // Return the userCredential
        return userCredential;
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
        return null;
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
      return null;
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
      return null;
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
    return null;
  }
}