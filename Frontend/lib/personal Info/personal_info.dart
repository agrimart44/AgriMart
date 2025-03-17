// import 'package:flutter/material.dart';

// class PersonalInformation extends StatefulWidget {
//   const PersonalInformation({super.key});

//   @override
//   PersonalInformationState createState() => PersonalInformationState();
// }

// class PersonalInformationState extends State<PersonalInformation> {
//   String name = "Rathnayake";
//   String gender = "Male";
//   String role = "Farmer";
//   String location = "Nuwara Eliya";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Image.asset(
//               'lib/assets/first_page_background.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Background-overlay
//           Center(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.8),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text(
//                     "Personal Information",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.person,
//                       size: 50,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   userInfo(Icons.person, "Full Name", name),
//                   userInfo(Icons.male, "Gender", gender),
//                   userInfo(Icons.work, "Farmer/Buyer", role),
//                   userInfo(Icons.location_on, "Location", location),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             left: 20,
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.pop(context); // Back button
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget userInfo(IconData icon, String title, String value) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: Colors.green,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 10),
//           Text(
//             "$title: ",
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:namer_app/main.dart';
import 'user_Service.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  PersonalInformationState createState() => PersonalInformationState();
}

class PersonalInformationState extends State<PersonalInformation> {
  final UserService _userService = UserService();
  
  // Default values that will be updated
  String name = "";
  String phoneNumber = "";
  String role = "";
  String location = "";
  List<String> cart = [];
  String email = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });
      
      final userData = await _userService.getUserDetails();
      
      setState(() {
        name = userData['fullName'] ?? userData['name'] ?? "Not available";
        phoneNumber = userData['phone_number'] ?? "Not available";
        role = userData['occupation'] ?? "Not available";
        location = userData['location'] ?? "Not available";
        email = userData['email'] ?? "Not available";
        
        // Handle cart data
        if (userData.containsKey('cart') && userData['cart'] is List) {
          cart = List<String>.from(userData['cart']);
        } else {
          cart = [];
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/first_page_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Background-overlay
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading 
                ? _buildLoadingWidget()
                : errorMessage.isNotEmpty
                  ? _buildErrorWidget()
                  : _buildUserInfoWidget(),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context); // Back button
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 20),
        Text(
          "Loading user data...",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }


  Widget _buildErrorWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 50),
        const SizedBox(height: 20),
        Text(
          errorMessage,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loadUserData,
          child: const Text("Retry"),
        ),
      ],
    );
  }

  Widget _buildUserInfoWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          userInfo(Icons.person, "Full Name", name),
          userInfo(Icons.phone, "Phone", phoneNumber),
          userInfo(Icons.email, "Email", email),
          userInfo(Icons.work, "Role", role),
          userInfo(Icons.location_on, "Location", location),
          userInfo(Icons.shopping_cart, "Cart Items", "${cart.length} items"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Refresh Data"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile screen
                  // You can implement this later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Edit Profile"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget userInfo(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}