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