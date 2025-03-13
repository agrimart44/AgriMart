import 'package:flutter/material.dart';

void main() {
    runApp(const ChangePasswordScreen());
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                body: Stack(
                children: [
        Container(
                decoration: const BoxDecoration(
                image: DecorationImage(
                image: AssetImage("assets/background.jpg"), // Background image
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
        // Back button and menu icon
        Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
        style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

        // Title and description
                    const Text(
                "Update your mobile number",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                "Add a mobile phone  number so you can always "
                "get back into your account. It also helps us notify you.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

        // Password Input Fields
        buildPasswordField("Re-enter mobile number"),
        const SizedBox(height: 20),
        const Text(
                "Invalid mobile number. Please re-enter a valid mobile number",
                style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                    const SizedBox(height: 20),

        Align(
          alignment: Alignment.center,
          // Change Password Button
        child:SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                onPressed: () {},
        style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                          ),
                        ),
        child: const Text(
                "Next",
                style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
        )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    }

    Widget buildPasswordField(String hint) {
        return TextField(
                obscureText: true,
                decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
        ),
      ),
    );
    }
}