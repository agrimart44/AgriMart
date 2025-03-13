import 'package:flutter/material.dart';
import 'package:namer_app/buyer_view_page/buyer_view.dart';
import 'package:namer_app/buyer_view_page/crop.dart';

class CropLargeView extends StatefulWidget {
  final Crop crop;

  const CropLargeView({super.key, required this.crop});

  @override
  State<CropLargeView> createState() => _CropLargeViewState();
}

class _CropLargeViewState extends State<CropLargeView> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: const Color(0xFFD3D3D3),
        title: Text(widget.crop.name),
      ),
      backgroundColor: const Color(0xFFD3D3D3),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Use widget.crop.imagePath instead of hardcoded path
              Image.asset(
                widget.crop.imagePath,
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
                      'Rs.${widget.crop.price.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                        color: Color(0xFF23D048),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Rest of the code remains the same
                    const SizedBox(height: 8),
                    Text(
                      widget.crop.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Location: ${widget.crop.location}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Farmer: ${widget.crop.farmerName}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Harvest Date: ${_formatDate(widget.crop.harvestDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact: ${widget.crop.contactNumber}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '34 Watching This Now',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    _buildQuantitySelector(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Chat with Seller functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23D048),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${quantity}kg of ${widget.crop.name} added to cart'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF23D048),
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
                              backgroundColor: const Color(0xFF23D048),
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

  // Rest of the methods remain the same
  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text("Quantity (kg): ", style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    setState(() {
                      quantity--;
                    });
                  }
                },
              ),
              Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}