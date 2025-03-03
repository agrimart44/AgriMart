import 'package:flutter/material.dart';

void main() {
    runApp(SecurityScreen());
}

class SecurityScreen extends StatelessWidget {
    SecurityScreen({super.key});

    List<String> options = ['option 1', 'option 2'];

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
                image:
        AssetImage("assets/background.jpg"), // Background image
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
        Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        IconButton(
                icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
        style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                "Add extra security to your account",
                style:
        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                "Two - factor authentication protects your account by requiring an additional code when you log in on a device that we don't recognize.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                "Choose your security method",
                style:
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
        Container(
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
        BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                          ),
                        ],
                      ),
        child: Row(
                children: [
        Radio(
                value: false,
                onChanged: (value) {},
                          ),
                          const Expanded(
                child: Text(
                "Log out of other devices. Choose this if someone else used your account.",
                style:
        TextStyle(fontSize: 14, color: Colors.grey),
                            ),
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
      ),
    );
    }

    Widget buildListTile(String title) {
        return ListTile(
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
    );
    }
}