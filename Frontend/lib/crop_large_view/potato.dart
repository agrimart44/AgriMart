import 'package:flutter/material.dart';
import 'package:namer_app/ChatScreen/chat_screen.dart';
import 'package:namer_app/ChatScreen/chat_service.dart';
import 'package:namer_app/ChatScreen/seller_chat_provider.dart';
import 'package:namer_app/buyer_view_page/crop.dart';
import 'package:namer_app/buyer_view_page/crop_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final ChatService _chatService = ChatService('xqww9xknukff');
  bool _isOpeningChat = false; // Add state to track chat opening status

   // Initialize ChatService


  @override
  void initState() {
    super.initState();
    _loadCropDetails();
  }

// Add this method to your CropLargeView class

Future<void> _openChatWithSeller() async {
  final chatProvider = Provider.of<SellerChatProvider>(context, listen: false);
  
  // Show loading indicator
  setState(() => _isOpeningChat = true);
  
  try {
    // Ensure user is connected to chat service
    final connected = await chatProvider.ensureConnected(context);
    if (!connected) {
      setState(() => _isOpeningChat = false);
      return;
    }
    
    // Get the seller ID from crop details
    final sellerId = _cropDetails.sellerId;
    print("Seller ID: $sellerId"); // Debug: Check seller ID value
    
    if (sellerId.isEmpty) {
      throw Exception("Seller ID not available");
    }
    
    // Create or join a chat channel with the seller
    final channel = await chatProvider.chatService.createOrJoinSellerChat(
      _cropDetails.id,
      sellerId,
      _cropDetails.farmerName,
    );
    
    // Navigate to chat screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            channelId: channel.id ?? '',
            cropId: _cropDetails.id,
          ),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start chat: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isOpeningChat = false);
    }
  }
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
          SnackBar(
            content: Text('$quantity kg of ${widget.crop.name} added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }
  
  Future<void> _callSeller(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(phoneUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Color.fromARGB(255, 0, 0, 0)),
        title: Text(
          widget.crop.name,
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: GoogleFonts.poppins(color: Colors.red)))
              : _buildCropDetails(),
    );
  }

  Widget _buildCropDetails() {
    Crop displayCrop = _isLoading ? widget.crop : _cropDetails;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(displayCrop),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayCrop.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Rs. ${displayCrop.price.toStringAsFixed(2)}/kg',
                        style: GoogleFonts.poppins(
                          color: Colors.green.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFarmerInfoCard(displayCrop),
                const SizedBox(height: 24),
                Text(
                  'About this Product',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayCrop.description,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(displayCrop),
                const SizedBox(height: 24),
                Text(
                  'Quantity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildQuantitySelector(),
                const SizedBox(height: 32),
                _buildButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Crop crop) {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: PageView.builder(
            itemCount: crop.imagePaths.length,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  crop.imagePaths[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 50, color: Colors.red),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: _buildImageIndicators(crop),
        ),
        if (crop.quantity < 5)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Only ${crop.quantity} left!',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageIndicators(Crop crop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        crop.imagePaths.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentImageIndex == index ? 16 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _currentImageIndex == index ? Colors.green : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildFarmerInfoCard(Crop crop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade100,
            child: Icon(
              Icons.person,
              size: 32,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.farmerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  crop.location,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      crop.contactNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _callSeller(crop.contactNumber),
                      child: Icon(
                        Icons.call,
                        size: 20,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Crop crop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            label: 'Harvest Date',
            value: _formatDate(crop.harvestDate),
            icon: Icons.calendar_today,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            label: 'Available Quantity',
            value: '${crop.quantity} kg',
            icon: Icons.scale,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            label: 'Location',
            value: crop.location,
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    Crop displayCrop = _isLoading ? widget.crop : _cropDetails;
    // Ensure quantity doesn't exceed available stock
    int maxQuantity = displayCrop.quantity;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: quantity > 1 ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: quantity > 1 ? Colors.green.shade200 : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 16,
                color: quantity > 1 ? Colors.green.shade700 : Colors.grey,
              ),
            ),
            onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                "$quantity kg",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: quantity < maxQuantity ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: quantity < maxQuantity ? Colors.green.shade200 : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 16,
                color: quantity < maxQuantity ? Colors.green.shade700 : Colors.grey,
              ),
              ),
            onPressed: quantity < maxQuantity ? () => setState(() => quantity++) : null,
          ),
        ],
      ),
    );
  }

// Modify the _buildButtons method
  Widget _buildButtons() {
    Crop displayCrop = _isLoading ? widget.crop : _cropDetails;
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isAddingToCart 
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Add to Cart',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _isOpeningChat ? null : _openChatWithSeller, // Use chat method instead of calling
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.green.shade700),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isOpeningChat ? 
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.green.shade700,
                    strokeWidth: 2,
                  ),
                ) :
                Icon(
                  Icons.chat, // Change to chat icon instead of phone
                  color: Colors.green.shade700,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Text(
                'Chat with Seller', // Update text
                style: GoogleFonts.poppins(
                  color: Colors.green.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Add an option to call if you still want that functionality
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _callSeller(displayCrop.contactNumber),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey.shade700,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Call Instead',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  


  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}