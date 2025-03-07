import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/Settings/settings_main_page.dart';

class ListCropScreen extends StatefulWidget {
  const ListCropScreen({super.key});

  @override
  State<ListCropScreen> createState() => _ListCropScreenState();
}

class _ListCropScreenState extends State<ListCropScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _photos = <String>[];
  final TextEditingController _harvestDataController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> _selectData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _harvestDataController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AgriMartAppBar(context, title: 'List Crop'),
      extendBodyBehindAppBar: true, // Allows body to extend behind AppBar
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/first_page_background.jpg', // Background image path
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3), // transparent overlay
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Upload Section
                    const Text(
                      'Add Photos',
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ..._photos.map((photo) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image, size: 40),
                              ),
                            )),
                        if (_photos.length < 3)
                          GestureDetector(
                            onTap: () => setState(() => _photos.add('')),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_a_photo),
                            ),
                          ),
                      ],
                    ),
                    const Divider(
                      height: 40, 
                      thickness: 1,
                      color: Colors.white70,
                    ),

                    // Listing Details
                    const Text(
                      'Listing Details',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    _buildTextField(
                      label: 'Name',
                      controller: null,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter crop name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    _buildTextField(
                      label: 'Description',
                      controller: null,
                      maxLines: 3,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 16),

                    // Price and Location Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Price (LKR)',
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Enter price' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Location',
                            controller: _locationController,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Enter location' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity and Harvest Date Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Quantity (KG)',
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Enter quantity' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Harvest Date',
                            controller: _harvestDataController,
                            readOnly: true,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.green,
                              ),
                              onPressed: () => _selectData(context),
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Select date' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5, // Add elevation for better visibility
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Handle form submission
                          }
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 18, 
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Add extra space at the bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Improved TextField builder for better visibility
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: Colors.black87, fontSize: 16),
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}