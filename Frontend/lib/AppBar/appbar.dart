import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namer_app/Settings/settings_main_page.dart';

/// Reusable Modern AppBar Widget
AppBar AgriMartAppBar(BuildContext context, {String title = "Shopping Cart"}) {
  return AppBar(
    backgroundColor: Colors.transparent, // Make AppBar background transparent
    elevation: 0, // Remove shadow
    title: Text(
      title, // Set the dynamic title
      style: TextStyle(
        color: Colors.black, // Set text color to black
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.notifications,
            color: const Color.fromARGB(255, 45, 179, 54)),
        onPressed: () {
          print('Show notifications');
        },
      ),
      IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppSettings()),
          );
        },
      ),
    ],
  );
}
