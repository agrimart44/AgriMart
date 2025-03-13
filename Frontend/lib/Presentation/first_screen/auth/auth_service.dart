
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // Add this import

// class AuthService {
//   // Instance of FirebaseAuth
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Secure storage instance
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

//   // URL for getting Stream token
//   final String _streamTokenUrl = 'http://192.168.43.27:8000/get-stream-jwt/';

//   // Method to get Stream token
//   Future<String> getStreamToken(String userId) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_streamTokenUrl),
//         body: {'user_id': userId},
//       );

//       // Check if the response is successful (HTTP status code 200)
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         String token = responseBody['token'];

//         // Store the token securely in the device storage
//         await _secureStorage.write(key: 'stream_token', value: token);

//         return token;
//       } else {
//         throw Exception('Failed to get Stream token');
//       }
//     } catch (e) {
//       print("Error fetching Stream token: $e");
//       throw Exception('Failed to connect to backend');
//     }
//   }

//   // Function to retrieve the stored Stream token
//   Future<String?> getStoredStreamToken() async {
//     return await _secureStorage.read(key: 'stream_token');
//   }

//   // Function to delete the stored Stream token (e.g., on logout)
//   Future<void> deleteStoredToken() async {
//     await _secureStorage.delete(key: 'stream_token');
//   }

//   // Sign in with email and password
//   Future<UserCredential> signinWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
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
//           errorMessage = 'An error occurred. Please try again later.';
//       }
//       throw Exception(errorMessage);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//     await deleteStoredToken();  // Optional: clear stored token on sign-out
//   }

//   // Sign up with email and password
//   Future<UserCredential> signupWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Error signing up: ${e.code}');
//     }
//   }


//     void authenticateWithStream() async {
//     try {
//       String? token = await AuthService().getStoredStreamToken();

//       if (token != null) {
//         // Use the token for further authentication with Stream API
//         print('Stream Token: $token');
//       } else {
//         print('No Stream token found');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }

// }

// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService {
//   // Instance of FirebaseAuth
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  
//   // Secure storage instance
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
//   // URL for getting Stream token
//   final String _streamTokenUrl = 'http://192.168.43.27:8000/get-stream-jwt/';
  
//   // Method to get Stream token
//   Future<String> getStreamToken(String userId) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_streamTokenUrl),
//         body: {'user_id': userId},
//       );
      
//       // Check if the response is successful (HTTP status code 200)
//       if (response.statusCode == 200) {
//         final responseBody = json.decode(response.body);
//         String token = responseBody['token'];
        
//         // Store the token securely in the device storage
//         await _secureStorage.write(key: 'stream_token', value: token);
        
//         return token;
//       } else {
//         throw Exception('Failed to get Stream token');
//       }
//     } catch (e) {
//       print("Error fetching Stream token: $e");
//       throw Exception('Failed to connect to backend');
//     }
//   }
  
//   // Function to retrieve the stored Stream token
//   Future<String?> getStoredStreamToken() async {
//     return await _secureStorage.read(key: 'stream_token');
//   }
  
//   // Function to store user ID in secure storage
//   Future<void> storeUserId(String userId) async {
//     await _secureStorage.write(key: 'user_id', value: userId);
//   }
  
//   // Function to retrieve the stored user ID
//   Future<String?> getStoredUserId() async {
//     return await _secureStorage.read(key: 'user_id');
//   }
  
//   // Function to delete the stored Stream token (e.g., on logout)
//   Future<void> deleteStoredToken() async {
//     await _secureStorage.delete(key: 'stream_token');
//   }
  
//   // Sign in with email and password
//   Future<UserCredential> signinWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Store the user ID after successful sign-in
//       await storeUserId(userCredential.user!.uid);
      
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
//           errorMessage = 'An error occurred. Please try again later.';
//       }
//       throw Exception(errorMessage);
//     }
//   }
  
//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//     await deleteStoredToken();
//     await _secureStorage.delete(key: 'user_id'); // Also clear stored user ID on sign-out
//   }
  
//   // Sign up with email and password
//   Future<UserCredential> signupWithEmailpassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
      
//       // Store the user ID after successful sign-up
//       await storeUserId(userCredential.user!.uid);
      
//       return userCredential;
//     } on FirebaseAuthException catch (e) {
//       throw Exception('Error signing up: ${e.code}');
//     }
//   }
  
//   void authenticateWithStream() async {
//     try {
//       String? token = await getStoredStreamToken();
      
//       if (token != null) {
//         // Use the token for further authentication with Stream API
//         print('Stream Token: $token');
//       } else {
//         // If no token is found, try to get a new one if user ID is available
//         String? userId = await getStoredUserId();
//         if (userId != null) {
//           String newToken = await getStreamToken(userId);
//           print('New Stream Token obtained: $newToken');
//         } else {
//           print('No user ID found, cannot get Stream token');
//         }
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
// }


import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Secure storage instance
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // URL for getting Stream token - ensure this is correct and your server is running
  final String _streamTokenUrl = 'http://192.168.43.27:8000/get-stream-jwt/';
  
  // Method to get Stream token with better error handling
  Future<String> getStreamToken(String userId) async {
    try {
      print("Requesting Stream token for user: $userId");
      
      // Add headers to ensure proper content type
      final response = await http.post(
        Uri.parse(_streamTokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'user_id': userId},
      );
      
      print("Stream token response status: ${response.statusCode}");
      
      // Check if the response is successful (HTTP status code 200)
      if (response.statusCode == 200) {
        try {
          final responseBody = json.decode(response.body);
          
          if (responseBody.containsKey('token')) {
            String token = responseBody['token'];
            print("Successfully received Stream token");
            
            // Store the token securely in the device storage
            await _secureStorage.write(key: 'stream_token', value: token);
            
            return token;
          } else {
            print("Token key not found in response: $responseBody");
            throw Exception('Invalid token response format');
          }
        } catch (e) {
          print("Error parsing JSON response: $e");
          print("Response body: ${response.body}");
          throw Exception('Failed to parse token response');
        }
      } else {
        print("Failed to get token. Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception('Failed to get Stream token: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching Stream token: $e");
      throw Exception('Failed to connect to backend: $e');
    }
  }
  
  // Function to retrieve the stored Stream token
  Future<String?> getStoredStreamToken() async {
    final token = await _secureStorage.read(key: 'stream_token');
    if (token != null) {
      print("Retrieved stored Stream token");
    } else {
      print("No stored Stream token found");
    }
    return token;
  }
  
  // Function to store user ID in secure storage
  Future<void> storeUserId(String userId) async {
    await _secureStorage.write(key: 'user_id', value: userId);
    print("User ID stored: $userId");
  }
  
  // Function to retrieve the stored user ID
  Future<String?> getStoredUserId() async {
    final userId = await _secureStorage.read(key: 'user_id');
    if (userId != null) {
      print("Retrieved stored user ID: $userId");
    } else {
      print("No stored user ID found");
    }
    return userId;
  }
  
  // Function to delete the stored Stream token (e.g., on logout)
  Future<void> deleteStoredToken() async {
    await _secureStorage.delete(key: 'stream_token');
    print("Stream token deleted from storage");
  }
  
  // Sign in with email and password
  Future<UserCredential> signinWithEmailpassword(String email, String password) async {
    try {
      print("Attempting to sign in user: $email");
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("User signed in successfully: ${userCredential.user?.uid}");
      
      // Store the user ID after successful sign-in
      await storeUserId(userCredential.user!.uid);
      
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
          errorMessage = 'Authentication error: ${e.code}';
      }
      print("Sign-in error: $errorMessage");
      throw Exception(errorMessage);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    print("Signing out user");
    await _auth.signOut();
    await deleteStoredToken();
    await _secureStorage.delete(key: 'user_id'); // Also clear stored user ID on sign-out
    print("User signed out, credentials cleared");
  }
  
  // Sign up with email and password
  Future<UserCredential> signupWithEmailpassword(String email, String password) async {
    try {
      print("Attempting to create new user: $email");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("User created successfully: ${userCredential.user?.uid}");
      
      // Store the user ID after successful sign-up
      await storeUserId(userCredential.user!.uid);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Sign-up error: ${e.code}");
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Error signing up: ${e.code}';
      }
      throw Exception(errorMessage);
    }
  }
  
  // Improved Stream authentication method with proper error handling
  Future<String> authenticateWithStream() async {
    try {
      // First try to get stored token
      String? token = await getStoredStreamToken();
      
      if (token != null) {
        print('Using stored Stream token');
        return token;
      } else {
        // If no token is found, try to get a new one if user ID is available
        String? userId = await getStoredUserId();
        if (userId != null) {
          print('Getting new Stream token for user: $userId');
          String newToken = await getStreamToken(userId);
          print('New Stream token obtained successfully');
          return newToken;
        } else {
          print('No user ID found, cannot get Stream token');
          throw Exception('No authenticated user found');
        }
      }
    } catch (e) {
      print('Stream authentication error: $e');
      throw Exception('Failed to authenticate with Stream: $e');
    }
  }
}