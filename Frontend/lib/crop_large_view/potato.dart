import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropLargeView extends StatefulWidget {
  const CropLargeView({super.key});

  @override
  State<CropLargeView> createState() => _CropLargeViewState();
}

class _CropLargeViewState extends State<CropLargeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: const Color(0xFFD3D3D3),
      ),
      backgroundColor: const Color(0xFFD3D3D3),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'lib/assets/potato.jpg',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs.210/kg',
                      style: const TextStyle(
                        color: Color(0xFF23D048),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Premium-quality potatoes sourced from the fertile lands of Nuwara Eliya, harvested on June 15, 2024. Available at just Rs. 210 per kilogram, these potatoes are ideal for a variety of dishes, offering a rich texture and delightful flavor to enhance your meals.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 16),
                    const Text(
                      '34 Watching This Now',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Chat with Seller functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23D048), // Button color
                            ),
                            child: const Text('Chat with Seller', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add to cart functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23D048), // Button color
                            ),
                            child: const Text('Add to cart', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Buy now functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23D048), // Button color
                            ),
                            child: const Text('Buy now', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}