import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';
import 'package:namer_app/Settings/settings_main_page.dart';
import 'package:namer_app/list_crops/listcrop.dart';
import 'package:namer_app/buyer_view_page/buyer_view.dart';
// Import the chat list page
import 'package:namer_app/ChatScreen/chat_list_page.dart'; // Add this import

class FarmerView extends StatefulWidget {
  const FarmerView({Key? key}) : super(key: key);

  @override
  FarmerViewState createState() => FarmerViewState();
}

class FarmerViewState extends State<FarmerView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends the body behind AppBar
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent, // Make AppBar transparent
      //   elevation: 0, // Remove shadow
      //   title: const Text(
      //     'AgriMart',
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.notifications,
      //           color: const Color.fromARGB(255, 45, 179, 54)),
      //       onPressed: () {
      //         print('Show notifications');
      //       },
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.menu),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => AppSettings()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      appBar: AgriMartAppBar(context, title: 'AgriMart'),
      body: Stack(
        children: [
          Image.asset(
            'lib/assets/first_page_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                _buildSearchBar(),
                _buildViewToggleButtons(),
                _buildDashboardGrid(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for articles, technologies, or topics...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[900]),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                print('Search button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // Replace current screen with Buyer View when clicked
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BuyerView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Buyer View'),
          ),
          const SizedBox(width: 25),
          ElevatedButton(
            onPressed: () {
              // No action needed when already on Farmer View
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Farmer View'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20, // Reduced spacing
        crossAxisSpacing: 20, // Reduced spacing
        childAspectRatio: 1, // Ensures cards are square
        children: [
          _buildDashboardCard(
            'Market\nPrices\nTrends',
            Icons.trending_up,
            () {
              print('Navigate to Market Prices Trends page');
              // Implement navigation logic
            },
          ),
          _buildDashboardCard(
            'Negotiations',
            Icons.handshake,
            () {
              // Navigate to ChatListPage when Negotiations card is tapped
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
              print('Navigated to Negotiations (Chat List) page');
            },
          ),
          _buildDashboardCard(
            'List New\nCrop',
            Icons.add_circle_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListCropScreen()),
              );
              print('Navigate to List New Crop page');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
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
      selectedItemColor: Colors.green[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}