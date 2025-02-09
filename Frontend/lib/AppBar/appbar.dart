import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Modern AppBar Widget
AppBar buildModernAppBar(BuildContext context, {String title = "Shopping Cart"}) {
  return AppBar(
    title: Text(
      title, // Dynamic Title for different pages
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: Colors.white,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF39B54A), Color(0xFF248232)], // Modern gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
      onPressed: () => Navigator.pop(context),
    ),
    
  );
}
