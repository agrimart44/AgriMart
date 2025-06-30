import 'package:flutter/material.dart';
import 'package:namer_app/Settings/settings_main_page.dart';

/// Custom AppBar for the AgriMart application.
AppBar AgriMartAppBar(BuildContext context, {String title = "Shopping Cart"}) {
  return AppBar(
    backgroundColor: Colors.transparent, 
    elevation: 0, 
    title: Text(
      title, 
      style: TextStyle(
        color: Colors.black, 
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
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
