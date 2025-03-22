import 'package:flutter/material.dart';
import 'package:namer_app/AppBar/appbar.dart';
import 'package:namer_app/BottomNavigationBar/bottom_navigation_bar.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';
import 'package:namer_app/Presentation/Price_Analysis/Price_analysis.dart';
import 'package:namer_app/Settings/settings_main_page.dart';
import 'package:namer_app/list_crops/listcrop.dart';
import 'package:namer_app/buyer_view_page/buyer_view.dart';
import 'package:namer_app/ChatScreen/chat_list_page.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FarmerView extends StatefulWidget {
  const FarmerView({super.key});

  @override
  FarmerViewState createState() => FarmerViewState();
}

class FarmerViewState extends State<FarmerView> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AgriMartAppBar(context, title: 'AgriMart'),
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with welcome message and gradient
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Farmer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage your agricultural business',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade900.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Quick action header with modern design
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade200,
                              Colors.grey.shade50,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scrollable content (dashboard grid)
              Expanded(
                child: _buildDashboardGrid(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShoppingCartPage()),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FarmerView()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9, // Slightly taller cards for more content
        children: [
          _buildDashboardCard(
            //'Market\nPrices',
            AppLocalizations.of(context)!.market_prices,
            Icons.trending_up_rounded,
            'Track market trends',
            () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  VegetableAnalysisScreen()),
              );
            },
            const Color(0xFF27AE60), // Green
            [const Color(0xFF6FCF97), const Color(0xFF27AE60)], // Gradient green
          ),
          _buildDashboardCard(
            //'Negotiations',
            AppLocalizations.of(context)!.negotiations,
            Icons.handshake_outlined,
            'Chat with buyers',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
            },
            const Color(0xFFF2994A), // Orange
            [const Color(0xFFFF8A65), const Color(0xFFFF5722)], // Gradient orange
          ),
          _buildDashboardCard(
            //'List Crop',
            AppLocalizations.of(context)!.list_crop,
            Icons.add_circle_outline_rounded,
            'Add new products',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListCropScreen()),
              );
            },
            const Color(0xFF27AE60), // Green
            [const Color(0xFF6FCF97), const Color(0xFF27AE60)], // Gradient green
          ),
          _buildDashboardCard(
            //'Market\nPlace',
            AppLocalizations.of(context)!.market_place,
            Icons.store_rounded,
            'Browse crops',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyerView()),
              );
            },
            const Color(0xFF9B51E0), // Purple
            [const Color(0xFFBB6BD9), const Color(0xFF9B51E0)], // Gradient purple
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
    Color mainColor,
    List<Color> gradientColors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background design element
              Positioned(
                right: -15,
                top: -15,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              
              // Card content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[1].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Title and subtitle
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748), // Dark gray for better contrast
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Decorative dot pattern (subtle)
              Positioned(
                bottom: 15,
                right: 15,
                child: _buildDotPattern(mainColor),
              ),
              
              // Hover effect indicator
              Positioned(
                right: 18,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: mainColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotPattern(Color color) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 10,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 20,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}