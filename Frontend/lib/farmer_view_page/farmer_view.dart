import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';
import 'package:namer_app/Settings/settings_main_page.dart';
import 'package:namer_app/list_crops/listcrop.dart';
import 'package:namer_app/buyer_view_page/buyer_view.dart';
import 'package:namer_app/ChatScreen/chat_list_page.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AgriMartAppBar(context, title: 'AgriMart'),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'lib/assets/first_page_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          
          // Fixed position elements (search bar and toggle buttons)
          Column(
            children: [
              const SizedBox(height: 100), // Space for app bar
              _buildSearchBar(),
              _buildViewToggleButtons(),
              
              // Scrollable content (only the dashboard grid)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildDashboardGrid(),
                ),
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
          
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
            );
          } else if (index == 2) {
            print('Navigate to Profile page');
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced vertical margin
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced vertical padding
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
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
        mainAxisSpacing: 15, // Further reduced spacing
        crossAxisSpacing: 15, // Further reduced spacing
        childAspectRatio: 1, // Square cards
        children: [
          _buildDashboardCard(
            'Market\nPrices\nTrends',
            Icons.trending_up,
            () {
              print('Navigate to Market Prices Trends page');
            },
          ),
          _buildDashboardCard(
            'Negotiations',
            Icons.handshake,
            () {
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}