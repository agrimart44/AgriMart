// import 'package:flutter/material.dart';
// //import 'app_settings.dart';

// class BuyerView extends StatefulWidget {
//   const BuyerView({super.key});

//   @override
//   BuyerViewState createState() => BuyerViewState();
// }

// class BuyerViewState extends State<BuyerView> {
//   int notificationCount = 0;
//   int _selectedIndex = 0;
//   String? _selectedDistrict;
//   String? _selectedCategory;
//   OverlayEntry? _overlayEntry;

//   final List<String> _districts = [
//     'Colombo',
//     'Gampaha',
//     'Kalutara',
//     'Kandy',
//     'Matale',
//     'Nuwara Eliya',
//     'Galle',
//     'Matara',
//     'Hambantota',
//     'Jaffna',
//     'Kilinochchi',
//     'Mannar',
//     'Vavuniya',
//     'Mullaitivu',
//     'Batticaloa',
//     'Ampara',
//     'Trincomalee',
//     'Kurunegala',
//     'Puttalam',
//     'Anuradhapura',
//     'Polonnaruwa',
//     'Badulla',
//     'Monaragala',
//     'Ratnapura',
//     'Kegalle'
//   ];

//   final List<String> _categories = ['Potato', 'Tomato', 'Brinjal', 'Carrot'];

//   final GlobalKey _locationButtonKey = GlobalKey();
//   final GlobalKey _categoryButtonKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque, // Detect taps outside widgets
//       onTap: () {
//         if (_overlayEntry != null) {
//           _overlayEntry?.remove();
//           _overlayEntry = null;
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('AgriMART'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.notifications),
//               onPressed: () {
//                 setState(() => notificationCount = 0);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 // Navigator.push(
//                 //   context,
//                 //   MaterialPageRoute(builder: (context) => const AppSettings()),
//                 // );
//               },
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             _buildSearchBar(),
//             _buildFilterButtons(),
//             _buildViewToggleButtons(),
//             const SizedBox(
//                 height: 20), // Added a gap between buttons and th card
//             Expanded(
//               child: _buildProductList(),
//             ),
//           ],
//         ),

//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             setState(() => _selectedIndex = index);
//           },
//           selectedItemColor: Colors.green[600],
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.shopping_cart), label: 'Cart'),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//           ],
//         ),
//       ),
//     );
//   }
import 'package:flutter/material.dart';
//import 'app_settings.dart';

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
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Monaragala',
    'Ratnapura',
    'Kegalle'
  ];

  final List<String> _categories = ['Potato', 'Tomato', 'Brinjal', 'Carrot'];

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
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0, // Remove shadow
          title: const Text(
            'AgriMART',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                setState(() => notificationCount = 0);
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const AppSettings()),
                // );
              },
            ),
          ],
        ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          selectedItemColor: Colors.green[600],
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
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
      child: Row(
        children: [
          _buildAllButton(),
          const SizedBox(width: 20),
          _buildLocationButton(),
          const SizedBox(width: 20),
          _buildCategoryButton(),
        ],
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
        _locationButtonKey.currentContext!.findRenderObject() as RenderBox;
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
      child: Row(
        children: [
          _buildToggleButton('Buyer View', true),
          const SizedBox(width: 25),
          _buildToggleButton('Farmer View', false),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green : Colors.white,
        foregroundColor: isActive ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(label),
    );
  }

  Widget _buildProductList() {
    // This is a placeholder.
    // this would fetch data from list of crops.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: 1, // Replace with actual number of products
        itemBuilder: (context, index) {
          return _buildProductCard(
            name: 'Product Name',
            location: 'Location',
            harvestDate: DateTime.now(),
            price: 100.0,
            rating: 4.5,
            // imageUrl: '', // image
          );
        },
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String location,
    required DateTime harvestDate,
    required double price,
    required double rating,
    // required String imageUrl,
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
                      name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        Text(location),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Harvest Date: ${_formatDate(harvestDate)}'),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${price.toStringAsFixed(2)}/kg',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle view action
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
                        Container(
                          width: 140,
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
                // image: DecorationImage(
                //image: NetworkImage(imageUrl),
                // fit: BoxFit.cover,
              ),
            ),
            //),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    //return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${date.day}/${date.month}/${date.year}';
  }
}
