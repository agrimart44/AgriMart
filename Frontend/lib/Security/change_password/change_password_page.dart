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
                "Change password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                "Your password must be at least 6 characters and should "
                "include a combination of numbers, letters and special characters(!\$@%).",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

        // Password Input Fields
        buildPasswordField("Current password"),
                    const SizedBox(height: 12),
        buildPasswordField("New password"),
                    const SizedBox(height: 12),
        buildPasswordField("Retype new password"),
                    const SizedBox(height: 20),

        // Forgotten Password Section
                    const Text(
                "Forgotten your password?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
        Row(
                children: [
        Checkbox(
                value: false,
                onChanged: (value) {},
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Expanded(
                child: Text(
                "Log out of other devices. Choose this if someone else used your account.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

        // Change Password Button
        SizedBox(
                width: double.infinity,
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
                "Change Password",
                style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
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