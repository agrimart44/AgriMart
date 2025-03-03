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
      theme: ThemeData(
        textTheme: TextTheme(
          // Add arimo font
          bodyLarge: GoogleFonts.arimo(
            textStyle: const TextStyle(fontSize: 24),
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: GoogleFonts.arimo(
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
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
            Image.asset ('lib/assets/potato.jpg',
            width: 300,
            height:300,
            fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs.210/kg',
                    style: TextStyle(
                      color:Color(0xFF23D048),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Premium-quality potatoes sourced from the fertile lands of Nuwara Eliya, harvested on June 15, 2024. Available at just Rs. 210 per kilogram, these potatoes are ideal for a variety of dishes, offering a rich texture and delightful flavor to enhance your meals.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  SizedBox(height: 16),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}