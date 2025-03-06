import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ListCropScreen extends StatefulWidget {
  const ListCropScreen({super.key});

  @override
  State<ListCropScreen> createState() => _ListCropScreenState();
}

class _ListCropScreenState extends State<ListCropScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<File> _photos = [];
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && _photos.length < 3) {
      setState(() => _photos.add(File(image.path)));
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Crops'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PHOTO UPLOAD SECTION
              const Text(
                'Add Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Display existing photos
                  ..._photos.map((photo) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            // Photo thumbnail container
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(photo),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Remove button overlay
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () =>
                                    _removePhoto(_photos.indexOf(photo)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  // Add photo button (shown if less than 3 photos)
                  if (_photos.length < 5)
                    GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                ],
              ),
              const Divider(height: 40, thickness: 1),

              const Text(
                'Listing Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                    }
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
