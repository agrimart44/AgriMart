import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/Presentation/first_screen/auth/auth_service.dart';
import 'package:namer_app/Settings/settings_main_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/list_crops/listCropService.dart';
import 'package:namer_app/list_crops/locationpicker.dart';

class ListCropScreen extends StatefulWidget {
  const ListCropScreen({super.key});

  @override
  State<ListCropScreen> createState() => _ListCropScreenState();
}

class _ListCropScreenState extends State<ListCropScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _photos = <String>[];
  final TextEditingController _cropNameController =
      TextEditingController(); // Added controller
  final TextEditingController _descriptionController =
      TextEditingController(); // Added controller
  final TextEditingController _harvestDataController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double? _latitude;
  double? _longitude;
  final TextEditingController _quantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Add service instances
  final CropService _cropService = CropService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

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

  // Function to show image source selection dialog
  Future<void> _showImageSourceOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose an option',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  // Function to show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Your crop has been listed successfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to handle crop submission
  Future<void> _submitCrop() async {
    if (_formKey.currentState!.validate()) {
      if (_photos.isEmpty) {
        _showErrorDialog('Please add at least one photo of your crop');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get Firebase token
        final String? firebaseToken =
            await _authService.getStoredFirebaseToken();
        print("Fire base toke in $firebaseToken");

        if (firebaseToken == null) {
          throw Exception(
              'Authentication token not found. Please login again.');
        }
        // Upload crop details
        final result = await _cropService.uploadCrop(
          cropName: _cropNameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          location: _locationController.text,
          latitude: _latitude,
          longitude: _longitude,
          quantity: int.parse(_quantityController.text),
          harvestDate: _harvestDataController.text,
          imagePaths: _photos,
          firebaseToken: firebaseToken,
        );
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          _showSuccessDialog();
        } else {
          _showErrorDialog(result['error']);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLocation: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _locationController.text = result['address'];
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AgriMartAppBar(context, title: 'List Crop'),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'lib/assets/first_page_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3),
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
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(File(photo)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _photos.remove(photo);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (_photos.length < 3)
                          GestureDetector(
                            onTap: () => _showImageSourceOptions(context),
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
                      controller: _cropNameController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Enter crop name' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    _buildTextField(
                      label: 'Description',
                      controller: _descriptionController,
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
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value!) == null) {
                                return 'Enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Location',
                            controller: _locationController,
                            readOnly:
                                true, // Make it read-only since we'll select with map
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.location_on,
                                color: Colors.green,
                              ),
                              onPressed: _openLocationPicker,
                            ),
                            validator: (value) => value?.isEmpty ?? true
                                ? 'Select location'
                                : null,
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
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Enter quantity';
                              }
                              if (int.tryParse(value!) == null) {
                                return 'Enter valid quantity';
                              }
                              return null;
                            },
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
                          elevation: 5,
                        ),
                        onPressed: _isLoading ? null : _submitCrop,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
        labelStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
