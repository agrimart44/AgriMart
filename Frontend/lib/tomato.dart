import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Home'), // Set Home Widget
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: const Color(0xFFD3D3D3),
      ),
      backgroundColor: const Color(0xFFD3D3D3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'lib/assets/tomato.jpg', // Ensure this file exists
              width: 380,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs.120/kg',
                    style: TextStyle(
                      color:Color(0xFF23D048),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enjoy fresh, juicy tomatoes grown in the lush fields of Nuwara Eliya.Harvested on June 13, 2024, these tomatoes are perfect for salads, cooking, or snacking. Known for their vibrant color and rich flavor, they bring the taste of freshness to your table.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),
                  Text(
                    '34 Watching This Now',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Chat with Seller functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF23D048), // Button color
                          ),
                          child: Text('Chat with Seller',style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Add to cart functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFF23D048), // Button color
                          ),
                          child: Text('Add to cart',style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Buy now functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF23D048), // Button color
                          ),
                          child: Text('Buy now',style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}