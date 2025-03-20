import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';
import 'package:namer_app/Settings/settings_main_page.dart';
import 'package:namer_app/list_crops/listcrop.dart';
import 'package:namer_app/buyer_view_page/buyer_view.dart';
import 'package:namer_app/ChatScreen/chat_list_page.dart';

// import localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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

          // Main content layout with SafeArea to respect system UI
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60), // Adjusted space for app bar
                _buildSearchBar(),

                // Scrollable content (dashboard grid)
                Expanded(
                  child: _buildDashboardGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            // Navigate to Shopping Cart Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
            );
          } else if (index == 0) {
            // Navigate to Farm View Page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmerView()),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                // Localized string added for search
                AppLocalizations.of(context)!.search,

                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05, // Slightly wider than tall to fit content better
        children: [
          _buildDashboardCard(
            // Localized string for market prices
            AppLocalizations.of(context)!.market_prices,
            //'Market\nPrices',
            Icons.trending_up,
                () {
              print('Navigate to Market Prices Trends page');
            },
          ),
          _buildDashboardCard(
            // Localized string for negotiations
            AppLocalizations.of(context)!.negotiations,
            //'Negotiations',
            Icons.handshake_outlined,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
              print('Navigated to Negotiations (Chat List) page');
            },
          ),
          _buildDashboardCard(
            //local text for list crop
            AppLocalizations.of(context)!.list_crop,
            //'List Crop',
            Icons.add_circle_outline,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListCropScreen()),
              );
              print('Navigate to List New Crop page');
            },
          ),
          _buildDashboardCard(
            'Market\nPlace',
            Icons.store_outlined,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerView()),
              );
              print('Navigate to Market Place (Buyer View) page');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.green.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // This helps with overflow
            children: [
              Icon(
                icon,
                size: 40, // Reduced from 48 to avoid overflow
                color: Colors.green,
              ),
              const SizedBox(height: 8), // Reduced spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14, // Reduced from 16 to fit better
                    fontWeight: FontWeight.bold,
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

// import 'package:flutter/material.dart';
// import 'package:namer_app/l10n/app_localizations.dart'; // Correct import
//
// class FarmerView extends StatefulWidget {
//   const FarmerView({Key? key}) : super(key: key);
//
//   @override
//   FarmerViewState createState() => FarmerViewState();
// }
//
// class FarmerViewState extends State<FarmerView> {
//   int _selectedIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(AppLocalizations.of(context)!.marketPrices), // Using localized string
//       ),
//       body: Stack(
//         children: [
//           // Background image
//           Image.asset(
//             'lib/assets/first_page_background.jpg',
//             width: double.infinity,
//             height: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 const SizedBox(height: 60),
//                 _buildSearchBar(),
//                 Expanded(
//                   child: _buildDashboardGrid(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         selectedIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() => _selectedIndex = index);
//         },
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search for articles, technologies, or topics...',
//                 hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
//                 prefixIcon: Icon(Icons.search, color: Colors.grey[900]),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               ),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.only(right: 8),
//             child: ElevatedButton(
//               onPressed: () {
//                 print('Search button pressed');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               ),
//               child: const Text(
//                 'Search',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDashboardGrid() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: GridView.count(
//         crossAxisCount: 2,
//         shrinkWrap: true,
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//         childAspectRatio: 1.05,
//         children: [
//           _buildDashboardCard(
//             AppLocalizations.of(context)!.marketPrices, // Using localized string
//             Icons.trending_up,
//                 () {
//               print('Navigate to Market Prices Trends page');
//             },
//           ),
//           _buildDashboardCard(
//             AppLocalizations.of(context)!.negotiations, // Using localized string
//             Icons.handshake_outlined,
//                 () {
//               print('Navigated to Negotiations (Chat List) page');
//             },
//           ),
//           _buildDashboardCard(
//             AppLocalizations.of(context)!.listCrop, // Using localized string
//             Icons.add_circle_outline,
//                 () {
//               print('Navigate to List New Crop page');
//             },
//           ),
//           _buildDashboardCard(
//             AppLocalizations.of(context)!.marketPlace, // Using localized string
//             Icons.store_outlined,
//                 () {
//               print('Navigate to Market Place (Buyer View) page');
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.white, Colors.green.withOpacity(0.1)],
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 40,
//                 color: Colors.green,
//               ),
//               const SizedBox(height: 8),
//               FittedBox(
//                 fit: BoxFit.scaleDown,
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


