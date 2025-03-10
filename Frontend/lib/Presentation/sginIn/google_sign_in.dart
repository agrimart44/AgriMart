import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // User canceled the sign-in process
      return;
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
  }
}


// /import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';

// // Google Sign-In method
// Future<void> signInWithGoogle(BuildContext context) async {
//   try {
//     // Begin interactive sign-in process
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) {
//       // User canceled the sign-in
//       return;
//     }
    
//     // Obtain auth details from request
//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
//     // Create a new credential for Firebase
//     final OAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
    
//     // Sign in to Firebase with credential
//     await FirebaseAuth.instance.signInWithCredential(credential);
    
//     // Don't need to authenticate with Stream Chat here anymore
//     // This will be done in the Login class
//   } catch (e) {
//     debugPrint('Google Sign-In Error: $e');
//     rethrow; // Rethrow to be caught by the handleSocialSignIn method
//   }
// }

// // Facebook Sign-In method
// Future<void> signInWithFacebook(BuildContext context) async {
//   try {
//     // Begin the Facebook login process
//     final LoginResult result = await FacebookAuth.instance.login();
    
//     if (result.status == LoginStatus.success) {
//       // Obtain access token
//       final AccessToken? accessToken = result.accessToken;
      
//       if (accessToken == null) {
//         throw Exception('Could not retrieve Facebook access token');
//       }
      
//       // Create a credential for Firebase - use accessToken.token correctly
//       final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token ?? '');
      
//       // Sign in to Firebase with the credential
//       await FirebaseAuth.instance.signInWithCredential(credential);
      
//       // Don't need to authenticate with Stream Chat here anymore
//       // This will be done in the Login class
//     } else if (result.status == LoginStatus.cancelled) {
//       // User canceled the login
//       throw Exception('Facebook login was canceled');
//     } else {
//       // Login failed
//       throw Exception(result.message ?? 'Unknown Facebook login error');
//     }
//   } catch (e) {
//     debugPrint('Facebook Sign-In Error: $e');
//     rethrow; // Rethrow to be caught by the handleSocialSignIn method
//   }
// }

// extension on AccessToken {
//   get token => null;
// }