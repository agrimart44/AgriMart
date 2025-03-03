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
                "Enter code",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                "Enter the six degit code sent to your email",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),


        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
        ),),

        


                    

        Align(
          alignment: Alignment.center,
          // Change Password Button
        child:SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                onPressed: () {},
        style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                          ),
                        ),
        child: const Text(
                "Done",
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