import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:namer_app/list_crops/listCropService.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:basic_utils/basic_utils.dart'; // Add this import
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Add this import
import 'package:path_provider/path_provider.dart'; // Add this import


class ListCropScreen extends StatefulWidget {
  const ListCropScreen({super.key});

  @override
  State<ListCropScreen> createState() => _ListCropScreenState();
}

class _ListCropScreenState extends State<ListCropScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _photos = <String>[];
  final TextEditingController _cropNameController = TextEditingController(); // Added controller
  final TextEditingController _descriptionController = TextEditingController(); // Added controller
  final TextEditingController _harvestDataController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  double? _latitude; // To store the selected latitude
  double? _longitude; // To store the selected longitude
  
  // Add service instances
  final CropService _cropService = CropService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;

  // Flutter Local Notifications Plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize Flutter Local Notifications
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show Local Notification
  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode({'id': '1', 'status': 'done'}),
    );
  }

  // Show Local Notification with Image
  Future<void> _showNotificationWithImage(String title, String body, String imagePath) async {
    final String largeIconPath = await _saveFile(imagePath, 'largeIcon');
    final String bigPicturePath = await _saveFile(imagePath, 'bigPicture');

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: json.encode({'id': '1', 'status': 'done'}),
    );
  }

  // Helper method to save file
  Future<String> _saveFile(String filePath, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String newFilePath = '${directory.path}/$fileName';
    final File file = File(filePath);
    final File newFile = await file.copy(newFilePath);
    return newFile.path;
  }

  Future<void> _selectData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _harvestDataController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Function to show image source selection dialog
  Future<void> _showImageSourceOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.choose_an_option,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green[700]),
                title: Text(AppLocalizations.of(context)!.gallery),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green[700]),
                title: Text(AppLocalizations.of(context)!.camera),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }
  
  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.success, style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
          content: Text(AppLocalizations.of(context)!.crop_listed_successfully),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(color: Colors.green[700])),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        );
      },
    );
  }
  
  // Function to show error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(errorMessage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  // Function to handle crop submission
  Future<void> _submitCrop() async {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        _showErrorDialog(AppLocalizations.of(context)!.add_at_least_one_photo);
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Get Firebase token
        final String? firebaseToken = await _authService.getStoredFirebaseToken();
        print("Firebase token: $firebaseToken");
        
        if (firebaseToken == null) {
          throw Exception(AppLocalizations.of(context)!.auth_token_not_found);
        }
        
        // Upload crop details with location coordinates
        final result = await _cropService.uploadCrop(
          cropName: _cropNameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          location: _locationController.text,
          quantity: int.parse(_quantityController.text),
          harvestDate: _harvestDataController.text,
          imagePaths: _photos,
          firebaseToken: firebaseToken,
          latitude: _latitude, // Add latitude from map picker
          longitude: _longitude, // Add longitude from map picker
        );
        
        setState(() {
          _isLoading = false;
        });
        
        if (result['success']) {
          _showSuccessDialog();
          // Send notification to other users
          await _sendNotificationToUsers();
        } else {
          _showErrorDialog(result['error']);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> _sendNotificationToUsers() async {
    final String accessToken = await getAccessToken();
    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/agri-mart-add65/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "topic": "all",
        "notification": {
          "title": "New Crop Listed",
          "body": "${_cropNameController.text} has listed a new crop."
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done"
        }
      }
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
      if (_photos.isNotEmpty) {
        await _showNotificationWithImage(
          "New Crop Listed",
          "${_cropNameController.text} has listed a new crop.",
          _photos[0], // Use the first photo as the image
        );
      } else {
        await _showNotification(
          "New Crop Listed",
          "${_cropNameController.text} has listed a new crop.",
        );
      }
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<String> getAccessToken() async {
    try {
      // Step 1: Hardcode the client_email and private_key
      final String clientEmail = "firebase-adminsdk-fbsvc@agri-mart-add65.iam.gserviceaccount.com";
      final String privateKey = """-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC6LMDBl/6ng1pp
I1kwWj61kFx1js2/zhizi7rlFJVp+mEFEJX/yvHvzHo/NL8a0V+1grK+WA5EyyGv
OmTO2e7ghY4/CcCTgVqXzYAhy+MjAvhJvYE74tWicBoslX2szckk9sL8PU0ZBZyr
8Ptp0Fm2p4jAs8qnH5vZBGgj/u/TXoaeFQ0ckZTMjY1yZsH7GsiiYgtAxQp/g1zj
ixTNrwHRTdXqh7La8pBInEtu1mTbrvbux3hZTs8UyBIUNQoUrlvyR66PXUwNvyn+
4D8bFGfLa6tPe5FbUptqJJsJNFyPau77TUuuZlfeWQ9stX4k6BjF9bx8OvzHq2ht
8W3ZIieHAgMBAAECggEANHS+nO14FXfHph8NFrgeuiaiPodNhpEJ2bDxqHEbxkAD
TRuGwAtNDs1U1nFEtUgwCOL5/PKvloeLhqVT2QqDqWRIF4/mYElOnr4Kr7sUVP2V
uqU4AAkiO4INhela/zD+Tzlt6AdXrUitA69DD2XimTnsKKuf2mXoEgYRV68RoMKi
lUm7ypdRTTuxQcEZn5RumqZ2h5pMuqnIODFdIYAcIMuzhuG7fkFEjqidIKryVIUD
p6W2pSXZ11ij3r79V5zlqiEgHphIQpSvK1uqntC8nh2NebTPQw+yD6TDv6Ry+fyp
FfSf4rTIYHM/RQmwCDJZ48J/N+dDMNRIyYdR1BrpxQKBgQDrvIGhrBz+FRyUz1sG
OX+fy/DfmQ1KDJbNOOgHFfUQAGu4LxgTyoRxSitWgL6N3HoZNuqlj9vOIr8hV1fr
K+GGQVLK62ZYfNQ+KUR+Yk8UA6TGP/9k5lEfDHSWCQikjC9i802K5+kbtcXWr5dm
QwgIZead3gYCW3aLkW5PFberbQKBgQDKLZ7pXZlrS3bJhZnxIsv2zzRMq62gbJ9z
9dbg5fOUw6AArf3YAKZQLu1YQm6OqBidzCPbXRAdN7wh7X4azea4qQlSI1MnZ4Hx
H3EYM7AzLpSt4SC6rC8TKd/bkgANryeDUPl+6xDzlC7vgbunNrVz5OqYlAnHE8U1
uvCVOskyQwKBgCbmycGjRHmNhFTuTwgc7vmwzwQnHrFMmIovTOL2daV5XE1dwCxr
7CVB5xr0Tf3dF20XyesebVh8FWxsHH8bk7DzELWZ2R7bIq9LYhk1IfWckFGC+CNv
eo2UIZ0syndVBvDeU7qLgMVo3sgJ3AMtJqM0JbWBkR5Md6iajEiSveeVAoGAfdXD
MJBXKta/SlJjLBhyRl1Uuduop060N+JtKXE2GANiFMo2UjilSwbKJsLCOPwaxiwG
rUPRAb5s09kTQe+hiJF9AaiG2uGrmL3vEBcrtc9qLocObeE5M34+nFTUv6+isjK1
9u6rkE9Mnzlp6Hs+mLGD6g9JvqRpfDWsA9Wg4C0CgYEAvAjwCwFTVa2aKaH/Kiu5
drN6u5c7/g2UQH2q7rgrK/W2tjZRNXOSL5nS7QJWnHykdSoSlB05iUiP7+tnbP07
mNst9vb3F3Z6XYljhaci/y2yMxKDZyH3851FqY0hQefd246v4KQnF4ysf79a8DR2
TfE7P3XEAKcV2z7PjdZocHI=
-----END PRIVATE KEY-----""";

      print('[DEBUG] Using hardcoded client_email: $clientEmail');

      // Step 2: Generate JWT Header
      final String jwtHeader = base64Url.encode(utf8.encode(json.encode({
        "alg": "RS256",
        "typ": "JWT"
      })));

      print('[DEBUG] Generated JWT Header: $jwtHeader');

      // Step 3: Generate JWT Claim Set
      final int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String jwtClaimSet = base64Url.encode(utf8.encode(json.encode({
        "iss": clientEmail,
        "scope": "https://www.googleapis.com/auth/firebase.messaging",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": currentTime + 3600,
        "iat": currentTime,
      })));

      print('[DEBUG] Generated JWT Claim Set: $jwtClaimSet');

      // Step 4: Combine JWT Header and Claim Set
      final String unsignedJwt = "$jwtHeader.$jwtClaimSet";

      print('[DEBUG] Combined JWT: $unsignedJwt');

      // Function to sign the JWT using the private key
      String signJwt(String unsignedJwt, String privateKey) {
        try {
          // Parse the private key using CryptoUtils
          final rsakey = CryptoUtils.rsaPrivateKeyFromPem(privateKey);

          // Create the signer with SHA-256 digest
          final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
            ..init(true, PrivateKeyParameter<RSAPrivateKey>(rsakey));

          // Sign the JWT
          final signature = signer.generateSignature(Uint8List.fromList(unsignedJwt.codeUnits));

          // Encode the signature in Base64 URL format and remove padding
          return base64Url.encode(signature.bytes).replaceAll('=', '');
        } catch (e) {
          throw Exception('[ERROR] Failed to sign JWT: $e');
        }
      }

      // Step 5: Sign the JWT
      final String jwtSignature = signJwt(unsignedJwt, privateKey);
      final String signedJwt = "$unsignedJwt.$jwtSignature";

      print('[DEBUG] Signed JWT: $signedJwt');

      // Step 6: Exchange JWT for Access Token
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
          "assertion": signedJwt,
        },
      );

      print('[DEBUG] OAuth2 Response Status Code: ${response.statusCode}');
      print('[DEBUG] OAuth2 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String accessToken = responseData['access_token'];
        print('[DEBUG] Successfully retrieved access token.');
        return accessToken;
      } else {
        throw Exception('[ERROR] Failed to get access token: ${response.body}');
      }
    } catch (e) {
      print('[ERROR] Error in getAccessToken: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context)!.list_new_crop,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // space between header and body
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // Photo Upload Section
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.crop_photos,
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.add_upto_3_photos,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _photos.isEmpty 
                          ? GestureDetector(
                              onTap: () => _showImageSourceOptions(context),
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.green[700],
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        AppLocalizations.of(context)!.tap_to_add_photos,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context)!.add_clear_photos,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _photos.length < 3 ? _photos.length + 1 : _photos.length,
                                    itemBuilder: (context, index) {
                                      if (index == _photos.length && _photos.length < 3) {
                                        // Add photo button
                                        return GestureDetector(
                                          onTap: () => _showImageSourceOptions(context),
                                          child: Container(
                                            width: 140,
                                            margin: const EdgeInsets.only(right: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                                style: BorderStyle.solid,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.green[700],
                                                  size: 36,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  AppLocalizations.of(context)!.add_photos,
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Photo preview
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 140,
                                              margin: const EdgeInsets.only(right: 12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  image: FileImage(File(_photos[index])),
                                                  fit: BoxFit.cover,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _photos.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index < _photos.length
                                            ? Colors.green[700]
                                            : Colors.grey[300],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                
                // Crop Details
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: Colors.green[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Crop Details',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      _buildTextField(
                        label: AppLocalizations.of(context)!.enter_crop_name,
                        hint: AppLocalizations.of(context)!.organic_tomatoes,
                        controller: _cropNameController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? AppLocalizations.of(context)!.enter_crop_name : null,
                      ),
                      const SizedBox(height: 18),

                      // Description Field
                      _buildTextField(
                        label: AppLocalizations.of(context)!.description,
                        hint: AppLocalizations.of(context)!.describe_your_crop,
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? AppLocalizations.of(context)!.enter_description : null,
                      ),
                      const SizedBox(height: 18),

                      // Price and Quantity Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: AppLocalizations.of(context)!.price_lkr,
                              hint: AppLocalizations.of(context)!.per_kg,
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.attach_money, size: 18),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!.enter_price;
                                }
                                if (double.tryParse(value!) == null) {
                                  return AppLocalizations.of(context)!.enter_valid_price;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              label: AppLocalizations.of(context)!.quantity,
                              hint: AppLocalizations.of(context)!.quantity_kg,
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.inventory_2_outlined, size: 18),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return AppLocalizations.of(context)!.enter_quantity;
                                }
                                if (int.tryParse(value!) == null) {
                                  return AppLocalizations.of(context)!.enter_valid_quantity;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Location and Harvest Date Row
                      _buildTextField(
                        label: AppLocalizations.of(context)!.location,
                        hint: AppLocalizations.of(context)!.crop_location,
                        controller: _locationController,
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                        validator: (value) => value?.isEmpty ?? true ? AppLocalizations.of(context)!.select_location : null,
                      ),
                      const SizedBox(height: 18),
                      
                      _buildTextField(
                        label: AppLocalizations.of(context)!.harvest_date,
                        hint: AppLocalizations.of(context)!.crop_harvest_date,
                        controller: _harvestDataController,
                        readOnly: true,
                        prefixIcon: const Icon(Icons.calendar_today, size: 18),
                        onTap: () => _selectData(context),
                        validator: (value) =>
                            value?.isEmpty ?? true ? AppLocalizations.of(context)!.select_date : null,
                      ),
                    ],
                  ),
                ),
                
                // List Crop Button
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoading ? null : _submitCrop,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20, 
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.listing_crop,
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_outlined, size: 20, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.list_crop,
                                  style: const TextStyle(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated TextField builder for modern look
  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(color: Colors.grey[800], fontSize: 15),
          maxLines: maxLines,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
}