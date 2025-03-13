import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';
import 'package:namer_app/buyer_view_page/crop.dart';
import 'package:namer_app/crop_large_view/potato.dart';
import 'package:namer_app/farmer_view_page/farmer_view.dart';

class BuyerView extends StatefulWidget {
  const BuyerView({super.key});

  @override
  BuyerViewState createState() => BuyerViewState();
}

class BuyerViewState extends State<BuyerView> {
  int notificationCount = 0;
  int _selectedIndex = 0;
  String? _selectedDistrict;
  String? _selectedCategory;
  OverlayEntry? _overlayEntry;

  final List<String> _districts = [
    'Colombo', 'Gampaha', 'Kalutara', 'Kandy', 'Matale','Nuwara Eliya','Galle','Matara','Hambantota','Jaffna','Kilinochchi','Mannar','Vavuniya',
    'Mullaitivu','Batticaloa','Ampara','Trincomalee','Kurunegala','Puttalam','Anuradhapura','Polonnaruwa','Badulla','Monaragala','Ratnapura','Kegalle'
  ];

  final List<String> _categories = ['Potato', 'Tomato', 'Brinjal', 'Carrot'];

  // Sample crops list
  final List<Crop> _crops = [
    Crop(
      id: '1',
      name: 'Fresh Potatoes',
      description: 'Freshly harvested potatoes from local farm. Perfect for cooking and frying.',
      price: 120.0,
      location: 'Nuwara Eliya',
      category: 'Potato',
      farmerName: 'K. Perera',
      contactNumber: '+94 77 123 4567',
      harvestDate: DateTime.now().subtract(const Duration(days: 2)),
      imagePath: 'lib/assets/potato.jpg',
      rating: 4.5,
    ),
    Crop(
      id: '2',
      name: 'Organic Tomatoes',
      description: 'Organic tomatoes grown without pesticides. Juicy and perfect for salads.',
      price: 180.0,
      location: 'Kandy',
      category: 'Tomato',
      farmerName: 'S. Fernando',
      contactNumber: '+94 76 234 5678',
      harvestDate: DateTime.now().subtract(const Duration(days: 1)),
      imagePath: 'lib/assets/tomato.jpg',
      rating: 4.8,
    ),
  ];

  final GlobalKey _locationButtonKey = GlobalKey();
  final GlobalKey _categoryButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Detect taps outside widgets
      onTap: () {
        if (_overlayEntry != null) {
          _overlayEntry?.remove();
          _overlayEntry = null;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true, // Extends the body behind AppBar
        appBar: AgriMartAppBar(context, title: 'AgriMart'),
        body: Stack(
          children: [
            Image.asset(
              'lib/assets/first_page_background.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Column(
              children: [
                const SizedBox(height: 100), // Space for AppBar
                _buildSearchBar(),
                _buildFilterButtons(),
                _buildViewToggleButtons(),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildProductList(),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          selectedIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            
            // Add navigation logic based on the selected index
            if (index == 1) { // Cart index
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
              );
            } else if (index == 2) { // Profile index
              // Navigate to profile page
              print('Navigate to Profile page');
              // Implement profile navigation
            }
            // For index 0 (Home), we're already on the home page
          },
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products or categories...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[900]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 2),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              ),
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildAllButton(),
            const SizedBox(width: 20),
            _buildLocationButton(),
            const SizedBox(width: 20),
            _buildCategoryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedDistrict = null;
          _selectedCategory = null;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('All'),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return ElevatedButton(
      key: _locationButtonKey,
      onPressed: () => _showOverlay(_districts, (value) {
        setState(() {
          _selectedDistrict = value;
        });
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_selectedDistrict ?? 'Location'),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildCategoryButton() {
    return ElevatedButton(
      key: _categoryButtonKey,
      onPressed: () => _showOverlay(_categories, (value) {
        setState(() {
          _selectedCategory = value;
        });
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_selectedCategory ?? 'Category'),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_drop_down, color: Colors.black),
        ],
      ),
    );
  }

  void _showOverlay(List<String> items, Function(String) onSelect) {
    final RenderBox renderBox =
        (_categoryButtonKey.currentContext?.findRenderObject() ?? 
         _locationButtonKey.currentContext?.findRenderObject()) as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final double buttonHeight = renderBox.size.height;
    final double overlayWidth = MediaQuery.of(context).size.width / 2;

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + buttonHeight,
        width: overlayWidth,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView(
              shrinkWrap: true,
              children: items.map((item) {
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    setState(() {
                      onSelect(item);
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildViewToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToggleButton('Buyer View', true),
            const SizedBox(width: 25),
            _buildToggleButton('Farmer View', false),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive) {
    return ElevatedButton(
      onPressed: () {
        if (label == 'Farmer View') {
          // Navigate to Farmer View when clicked
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerView()),
          );
        }
        // No action needed for Buyer View button when already on Buyer View
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(label),
    );
  }
  
  Widget _buildProductList() {
    List<Crop> filteredCrops = _crops;
    
    // Apply district filter
    if (_selectedDistrict != null) {
      filteredCrops = filteredCrops.where((crop) => crop.location == _selectedDistrict).toList();
    }
    
    // Apply category filter
    if (_selectedCategory != null) {
      filteredCrops = filteredCrops.where((crop) => crop.category == _selectedCategory).toList();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: filteredCrops.length,
        itemBuilder: (context, index) {
          final crop = filteredCrops[index];
          return _buildProductCard(
            crop: crop,
          );
        },
      ),
    );
  }

  Widget _buildProductCard({
    required Crop crop,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Product details
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        Text(crop.location),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Harvest Date: ${_formatDate(crop.harvestDate)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${crop.price.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < crop.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to CropLargeView
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CropLargeView(crop: crop),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('View'),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle watch later action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('Watch Later'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right side: Product image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(crop.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}