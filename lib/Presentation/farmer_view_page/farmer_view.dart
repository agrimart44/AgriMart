import 'package:flutter/material.dart';
//import 'app_settings.dart';
import 'package:namer_app/Presentation/list_crops/listcrop.dart';



class FarmerView extends StatefulWidget {
  const FarmerView({Key? key}) : super(key: key);

  @override
  FarmerViewState createState() => FarmerViewState();
}

class FarmerViewState extends State<FarmerView> {
  int notificationCount = 0;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriMART'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement logic to show notifications
              print('Show notifications');
              setState(() => notificationCount = 0);
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.menu),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => AppSettings()),
          //     );
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
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
                      hintText: 'Search for articles, Technologies, or topics...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[900]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 2),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          // View Toggle Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Buyer View
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
                    // Handle Farmer View
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
          ),
          // Dashboard Grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              mainAxisSpacing: 40,
              crossAxisSpacing: 25,
              children: [
                _buildDashboardCard(
                  'Market\nPrices\nTrends',
                  Icons.trending_up,
                      () {
                    // TODO: Navigate to Market Prices Trends page
                    print('Navigate to Market Prices Trends page');
                  },
                ),
                _buildDashboardCard(
                  'Negotiations',
                  Icons.handshake,
                      () {
                    // TODO: Navigate to Negotiations page
                    print('Navigate to Negotiations page');
                  },
                ),
                _buildDashboardCard(
                  'List New\nCrop',
                  Icons.add_circle_outline,
                      () {
                    // TODO: Navigate to List New Crop page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListCropScreen()),
    );
                    print('Navigate to List New Crop page');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: Implement navigation logic
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
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
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