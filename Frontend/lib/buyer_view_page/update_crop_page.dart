import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/buyer_view_page/crop_service.dart';
import 'package:namer_app/buyer_view_page/update_crop_form.dart';

class UpdateCropPage extends StatefulWidget {
  final String cropId;
  final String initialCropName;
  final String initialDescription;
  final double initialPrice;
  final String initialLocation;
  final int initialQuantity;
  final String initialHarvestDate;
  final List<dynamic> initialImageUrls;
  final Function onCropUpdated;

  const UpdateCropPage({
    super.key,
    required this.cropId,
    required this.initialCropName,
    required this.initialDescription,
    required this.initialPrice,
    required this.initialLocation,
    required this.initialQuantity,
    required this.initialHarvestDate,
    required this.initialImageUrls,
    required this.onCropUpdated,
  });

  @override
  State<UpdateCropPage> createState() => _UpdateCropPageState();
}

class _UpdateCropPageState extends State<UpdateCropPage> {
  final _formKey = GlobalKey<FormState>();
  final _cropNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  
  final CropService _cropService = CropService();
  final ImagePicker _picker = ImagePicker();
  
  List<dynamic> _existingImageUrls = [];
  List<File> _newImages = [];
  DateTime? _selectedHarvestDate;
  
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Theme colors
  final Color _primaryColor = Colors.green.shade800;
  final Color _secondaryColor = Colors.green.shade100;
  final Color _errorColor = Colors.red.shade700;
  final Color _backgroundColor = Colors.grey.shade50;
  final Color _cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }
  
  void _initializeFormData() {
    _cropNameController.text = widget.initialCropName;
    _descriptionController.text = widget.initialDescription;
    _priceController.text = widget.initialPrice.toString();
    _locationController.text = widget.initialLocation;
    _quantityController.text = widget.initialQuantity.toString();
    _existingImageUrls = List.from(widget.initialImageUrls);
    
    // Parse the harvest date
    if (widget.initialHarvestDate.isNotEmpty) {
      try {
        _selectedHarvestDate = DateTime.parse(widget.initialHarvestDate);
      } catch (e) {
        debugPrint('Error parsing harvest date: $e');
      }
    }
  }

  @override
  void dispose() {
    _cropNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Show dialog to choose camera or gallery
  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose Image Source",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera option
                    _imageSourceOption(
                      icon: Icons.camera_alt,
                      title: "Camera",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    // Gallery option
                    _imageSourceOption(
                      icon: Icons.photo_library,
                      title: "Gallery",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // Image source option widget
  Widget _imageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _secondaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: _primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _newImages.add(File(image.path));
        });
      }
    } catch (e) {
      _showSnackBar('Error selecting image: $e', isError: true);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedHarvestDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)), 
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              surface: _cardColor,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedHarvestDate) {
      setState(() {
        _selectedHarvestDate = picked;
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _errorColor : _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
    );
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedHarvestDate == null) {
      setState(() {
        _errorMessage = 'Please select a harvest date';
      });
      return false;
    }

    // Check if at least one image is available
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one image';
      });
      return false;
    }

    return true;
  }

  // Fixed: Ensure existing images are properly handled
  Future<void> _updateCrop() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fix: Make sure existing images are properly passed
      await _cropService.updateCrop(
        widget.cropId,
        _cropNameController.text.trim(),
        _descriptionController.text.trim(),
        double.parse(_priceController.text),
        _locationController.text.trim(),
        int.parse(_quantityController.text),
        DateFormat('yyyy-MM-dd').format(_selectedHarvestDate!),
        _existingImageUrls,  // Pass existing image URLs
        _newImages,
      );

      // Call the callback function to refresh the user crops list
      widget.onCropUpdated();
      
      // Navigate back to the previous screen
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Crop updated successfully');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update crop: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Crop',
            style: TextStyle(
              color: _errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this crop? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCrop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCrop() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _cropService.deleteCrop(widget.cropId);
      
      // Call the callback function to refresh the user crops list
      widget.onCropUpdated();
      
      // Navigate back to the previous screen
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar('Crop deleted successfully');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete crop: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      title: Align(
        alignment: Alignment.centerLeft, 
        child: const Text(
          'Update Crop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16), 
          child: TextButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: Colors.green),
            label: const Text(
              'Delete Crop',
              style: TextStyle(
                color: Colors.green, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),


      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Please wait...',
                    style: TextStyle(color: _primaryColor, fontSize: 16),
                  ),
                ],
              ),
            )
          : UpdateCropForm(
              formKey: _formKey,
              cropNameController: _cropNameController,
              descriptionController: _descriptionController,
              priceController: _priceController,
              locationController: _locationController,
              quantityController: _quantityController,
              existingImageUrls: _existingImageUrls,
              newImages: _newImages,
              selectedHarvestDate: _selectedHarvestDate,
              errorMessage: _errorMessage,
              primaryColor: _primaryColor,
              secondaryColor: _secondaryColor,
              errorColor: _errorColor,
              cardColor: _cardColor,
              onRemoveExistingImage: _removeExistingImage,
              onRemoveNewImage: _removeNewImage,
              onAddImage: _showImageSourceOptions,
              onSelectDate: _selectDate,
              onUpdate: _updateCrop,
              onCancel: () => Navigator.pop(context),
            ),
    );
  }
}