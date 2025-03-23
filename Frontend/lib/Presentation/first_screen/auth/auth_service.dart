import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:namer_app/Presentation/first_screen/first_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AuthService {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Keys for SharedPreferences storage
  final String _firebaseTokenKey = 'firebase_token';
  final String _streamTokenKey = 'stream_token';
  final String _userIdKey = 'user_id';
  
  // URL for getting Stream token - ensure this is correct and your server is running
  final String _streamTokenUrl = 'http://44.203.237.175:8000/get-stream-jwt/';

  // Method to get Firebase ID token and store it
  Future<String?> getFirebaseToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Force refresh the token to ensure it's not expired
        String? token = await user.getIdToken(true);
        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(_firebaseTokenKey, token);
          print("Firebase token refreshed and stored");
          return token;
        }
      }
      return null;
    } catch (e) {
      print("Error getting Firebase token: $e");
      return null;
    }
  }

  // Function to retrieve the stored Firebase token
  Future<String?> getStoredFirebaseToken() async {
    try {
      // First try to get a fresh token if possible
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          return await user.getIdToken(); // Try getting current token
        } catch (e) {
          print('Error getting fresh token: $e');
          // Fall back to stored token if refresh fails
        }
      }
      
      // Fall back to stored token
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_firebaseTokenKey);
      if (token != null) {
        print("Retrieved stored Firebase token");
      } else {
        print("No stored Firebase token found");
      }
      return token;
    } catch (e) {
      print("Error retrieving stored Firebase token: $e");
      return null;
    }
  }

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
            
            // Store the token in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(_streamTokenKey, token);
            
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
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_streamTokenKey);
      if (token != null) {
        print("Retrieved stored Stream token");
      } else {
        print("No stored Stream token found");
      }
      return token;
    } catch (e) {
      print("Error retrieving stored Stream token: $e");
      return null;
    }
  }

  // Function to store user ID in shared preferences
  Future<void> storeUserId(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      print("User ID stored: $userId");
    } catch (e) {
      print("Error storing user ID: $e");
    }
  }

  // Function to retrieve the stored user ID
  Future<String?> getStoredUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      if (userId != null) {
        print("Retrieved stored user ID: $userId");
      } else {
        print("No stored user ID found");
      }
      return userId;
    } catch (e) {
      print("Error retrieving stored user ID: $e");
      return null;
    }
  }

  // Function to delete the stored Stream token (e.g., on logout)
  Future<void> deleteStoredTokens() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_streamTokenKey);
      await prefs.remove(_firebaseTokenKey);
      print("All tokens deleted from storage");
    } catch (e) {
      print("Error deleting tokens: $e");
    }
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
      
      // Retrieve and store Firebase token
      await getFirebaseToken();

      // Subscribe user to personal topic
      await subscribeToUserSpecificTopic();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
        default:
          errorMessage = 'Authentication error: ${e.code}';
      }
      print("Sign-in error: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  // Sign out with navigation
  Future<void> signOut(BuildContext context) async {
    try {
      print("Signing out user");
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // Perform sign-out operations
      await _auth.signOut();
      await deleteStoredTokens();
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey); // Also clear stored user ID on sign-out
      
      print("User signed out, credentials cleared");
      
      // Navigate to first screen and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => FirstScreen(),
        ),
        (route) => false, // Removes all previous routes
      );
    } catch (e) {
      // Close loading dialog if there's an error
      Navigator.of(context).pop();
      
      print("Error during sign out: $e");
      throw Exception('Failed to sign out properly: $e');
    }
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
      
      // Retrieve and store Firebase token
      await getFirebaseToken();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Sign-up error: ${e.code}");
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
        case 'weak-password':
          errorMessage = 'The password is too weak.';
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
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

  // Initialize FCM
  Future<void> initializeFCM() async {
 
  try {
    print('[DEBUG] Starting FCM initialization...');

    // Request permissions for iOS
    print('[DEBUG] Requesting notification permissions...');
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('[SUCCESS] User granted notification permissions.');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('[ERROR] User denied notification permissions.');
    } else {
      print('[WARNING] Notification permissions are not determined.');
    }

    // Get the FCM token
    print('[DEBUG] Retrieving FCM token...');
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('[SUCCESS] FCM Token retrieved successfully: ${token.substring(0, 40)}... (truncated)');
    } else {
      print('[ERROR] FCM Token is null');
    }
    // Optionally, send the token to your backend server
    // await sendTokenToServer(token);
  
    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('[DEBUG] FCM Token refreshed: ${newToken.substring(0, 40)}... (truncated)');
      // Optionally, update the token on your backend server
      // updateTokenOnServer(newToken);
    });

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });

    // Handle app opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleIncomingNotification(message);
    });

    print('[SUCCESS] FCM initialization completed successfully.');
  } catch (e) {
    print('[ERROR] An error occurred during FCM initialization: $e');
  }
}

// Add this new method to your AuthService class
void _handleIncomingNotification(RemoteMessage message) async {
  try {
    // Get current user ID
    String? currentUserId = await getStoredUserId();
    
    // Extract data from the notification
    Map<String, dynamic> data = message.data;
    String? senderId = data['senderId'];
    String? notificationType = data['type'];
    
    // Debug log
    print('Received notification: type=$notificationType, senderId=$senderId, currentUserId=$currentUserId');
    
    // If this is a new crop notification and the current user is the sender, don't show it
    if (notificationType == 'new_crop' && 
        currentUserId != null && 
        senderId == currentUserId) {
      print('Ignoring notification from self (senderId=$senderId, currentUserId=$currentUserId)');
      return; // Skip showing the notification
    }
    
    // Continue with showing the notification
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    
    // If the notification has content and is on Android, show it
    if (notification != null && android != null) {
      // Existing notification display code...
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'general_channel',
            'General Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  } catch (e) {
    print('Error handling notification: $e');
  }
}

// Subscribe to a topic
Future<void> subscribeToTopic(String topic) async {
  try {
    print('[DEBUG] Subscribing to topic: $topic...');
    await _firebaseMessaging.subscribeToTopic(topic);
    print('[SUCCESS] Successfully subscribed to topic: $topic');
  } catch (e) {
    print('[ERROR] Failed to subscribe to topic: $topic. Error: $e');
  }
}

// Subscribe user to personal topic when signing in
Future<void> subscribeToUserSpecificTopic() async {
  try {
    String? userId = await getStoredUserId();
    if (userId != null) {
      await FirebaseMessaging.instance.subscribeToTopic(userId);
      print("Subscribed to user-specific topic: $userId");
    } else {
      print("Warning: Cannot subscribe to user-specific topic. User ID is null.");
    }
  } catch (e) {
    print("Error subscribing to user-specific topic: $e");
  }
}
  
}

