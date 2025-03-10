import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<UserCredential> signinWithEmailpassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      throw Exception(errorMessage);
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // Sign up with email and password
  Future<UserCredential> signupWithEmailpassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

}


// import 'package:firebase_auth/firebase_auth.dart'; // For FirebaseAuth
// import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat; // For StreamChatClient and User
// import 'package:http/http.dart' as http; // For HTTP requests
// import 'dart:convert'; // For JSON parsing
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage

// class AuthService {
//   // Instance of FirebaseAuth
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Instance of StreamChatClient
//   final stream_chat.StreamChatClient _streamChatClient = stream_chat.StreamChatClient(
//     'xqww9xknukff',  // Stream API Key
//   );

//   // Instance of FlutterSecureStorage to store JWT token securely
//   final storage = FlutterSecureStorage();

//   // Define the URL for your backend API to get the JWT token
//   final String apiUrl = 'http://127.0.0.1:8000/get-stream-jwt/';

//   // Sign in with email and password
//   Future<UserCredential> signinWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Once signed in with Firebase, authenticate the user with Stream
//       await authenticateWithStream(userCredential.user);

//       // Store the JWT token securely after successful login
//       String userId = userCredential.user!.uid;
//       String? token = await getJwtToken(userId);
//       if (token != null) {
//         await storeJwtToken(token);
//       }

//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       String errorMessage;
//       switch (e.code) {
//         case 'user-not-found':
//           errorMessage = 'No user found with this email.';
//           break;
//         case 'wrong-password':
//           errorMessage = 'Incorrect password.';
//           break;
//         case 'invalid-email':
//           errorMessage = 'Invalid email address.';
//           break;
//         default:
//           errorMessage = 'An error occurred. Please try again.';
//       }
//       throw Exception(errorMessage);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//     await _streamChatClient.disconnectUser();  // Disconnect the user from Stream Chat
//     await storage.delete(key: 'jwt_token');  // Remove the JWT token from secure storage
//   }

//   // Sign up with email and password
//   Future<UserCredential> signupWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Once signed up with Firebase, authenticate the user with Stream
//       await authenticateWithStream(userCredential.user);

//       // Store the JWT token securely after successful signup
//       String userId = userCredential.user!.uid;
//       String? token = await getJwtToken(userId);
//       if (token != null) {
//         await storeJwtToken(token);
//       }

//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.code);
//     }
//   }

//   // Helper function to authenticate the user with Stream
//     Future<void> authenticateWithStream(User? firebaseUser) async {
//       if (firebaseUser != null) {
//         final streamUser = stream_chat.User(
//           id: firebaseUser.uid,
//           extraData: {
//             'name': firebaseUser.displayName ?? 'No Name',
//             'image': firebaseUser.photoURL ?? 'https://placekitten.com/200/200',
//           },
//         );

//         // Retrieve the JWT token from secure storage
//         String? token = await retrieveJwtToken();
//         if (token != null) {
//           await _streamChatClient.connectUser(streamUser, token);  // Use the JWT token
//         } else {
//           throw Exception('JWT token not found');
//         }
//       }
//     }

//       // Function to get JWT token from the backend (Django API)
//     Future<String?> getJwtToken(String userID) async {
//       try {
//         final uri = Uri.parse('$apiUrl?user_id=$userID');
//         print('Sending request to: $uri'); // Log the request URL

//         final response = await http.get(uri);

//         print('Response Status: ${response.statusCode}');
//         print('Response Body: ${response.body}'); // Log the full response

//         if (response.statusCode == 200) {
//           final responseBody = json.decode(response.body);
//           if (responseBody['token'] != null) {
//             return responseBody['token']; // Token returned
//           } else {
//             throw Exception('Token not found in response');
//           }
//         } else {
//           throw Exception('Failed to retrieve JWT token');
//         }
//       } catch (e) {
//         print('Error getting JWT token: $e'); // Log error if something fails
//         throw Exception('Error getting JWT token: $e');
//       }
//     }



//   // Function to securely store the JWT token
//   Future<void> storeJwtToken(String token) async {
//     await storage.write(key: 'jwt_token', value: token);  // Securely store the token
//   }

//   // Function to retrieve the stored JWT token
//   Future<String?> retrieveJwtToken() async {
//     return await storage.read(key: 'jwt_token');  // Retrieve the token
//   }
// }
