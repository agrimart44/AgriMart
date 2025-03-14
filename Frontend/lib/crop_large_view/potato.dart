import 'package:flutter/material.dart';
import 'package:namer_app/buyer_view_page/crop.dart';
import 'package:namer_app/buyer_view_page/crop_service.dart';

class CropLargeView extends StatefulWidget {
  final Crop crop;

  const CropLargeView({super.key, required this.crop});

  @override
  State<CropLargeView> createState() => _CropLargeViewState();
}

class _CropLargeViewState extends State<CropLargeView> {
  final CropService _cropService = CropService();
  bool _isAddingToCart = false;
  int quantity = 1;
  int _currentImageIndex = 0;
  late Crop _cropDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCropDetails();
  }

  Future<void> _loadCropDetails() async {
    try {
      setState(() => _isLoading = true);
      // Get detailed information including farmer details
      _cropDetails = await _cropService.getCropDetails(widget.crop.id);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load crop details: $e';
        _cropDetails = widget.crop; // Fallback to passed crop
      });
    }
  }

  Future<void> _addToCart() async {
    // Check if requested quantity is available
    if (quantity > _cropDetails.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Requested quantity exceeds available stock (${_cropDetails.quantity} kg)')),
      );
      return;
    }
    
    setState(() => _isAddingToCart = true);
    try {
      await _cropService.addToCart(widget.crop.id, quantity);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$quantity kg of ${widget.crop.name} added to cart')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.crop.name),
        backgroundColor: const Color(0xFFD3D3D3),
      ),
      backgroundColor: const Color(0xFFD3D3D3),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
              : _buildCropDetails(),
    );
  }

  Widget _buildCropDetails() {
    Crop displayCrop = _isLoading ? widget.crop : _cropDetails;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(displayCrop),
            const SizedBox(height: 12),
            _buildImageIndicators(displayCrop),
            const SizedBox(height: 16),
            Text(
              'Rs. ${displayCrop.price.toStringAsFixed(2)}/kg', 
              style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(displayCrop.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Location: ${displayCrop.location}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Farmer: ${displayCrop.farmerName}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Harvest Date: ${_formatDate(displayCrop.harvestDate)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Contact: ${displayCrop.contactNumber}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Available Quantity: ${displayCrop.quantity} kg', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            _buildQuantitySelector(),
            const SizedBox(height: 24),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Crop crop) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: crop.imagePaths.length,
        onPageChanged: (index) => setState(() => _currentImageIndex = index),
        itemBuilder: (_, index) => Image.network(
          crop.imagePaths[index],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.error, size: 50, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildImageIndicators(Crop crop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        crop.imagePaths.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentImageIndex == index ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    Crop displayCrop = _isLoading ? widget.crop : _cropDetails;
    // Ensure quantity doesn't exceed available stock
    int maxQuantity = displayCrop.quantity;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Select Quantity (kg):", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove), 
              onPressed: quantity > 1 ? () => setState(() => quantity--) : null
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text("$quantity", style: const TextStyle(fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.add), 
              onPressed: quantity < maxQuantity ? () => setState(() => quantity++) : null
            ),
          ],
        ),
        if (maxQuantity < 5) 
          Text(
            "Only $maxQuantity kg left in stock!", 
            style: const TextStyle(color: Colors.red, fontStyle: FontStyle.italic)
          ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isAddingToCart ? null : _addToCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isAddingToCart 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}