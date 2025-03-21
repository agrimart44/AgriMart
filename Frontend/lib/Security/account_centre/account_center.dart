import 'package:flutter/material.dart';

class AccountCentre extends StatefulWidget {
  const AccountCentre({super.key});

  @override
  _AccountCentreState createState() => _AccountCentreState();
}

class _AccountCentreState extends State<AccountCentre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.green,
            shape: const CircleBorder(),
          ),
        ),
        title: const Text(
          "Account Centre", // Changed title
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/first_page_background.jpg"), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Title
                  const Text(
                    "Login details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  const Text(
                    "See what devices are used to log in to your accounts.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  // Section Header
                  const Text(
                    "Account login activity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "You're currently logged in on these devices:",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  const SizedBox(height: 20),

                  // Device Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        // Device Icon
                        const Icon(Icons.phone_android, size: 30, color: Colors.black54),
                        const SizedBox(width: 10),

                        // Device Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Xiaomi 13C",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Colombo, Sri Lanka.",
                              style: TextStyle(fontSize: 14, color: Colors.black45),
                            ),
                            Text(
                              "This device",
                              style: TextStyle(fontSize: 14, color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
