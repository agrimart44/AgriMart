import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/buyer_view_page/crop_service.dart';
import 'package:namer_app/buyer_view_page/update_crop_page.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:namer_app/ChatScreen/chat_list_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final CropService _cropService = CropService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _userCrops = [];
  Map<String, dynamic> _stats = {};
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserCropsAndStats();
  }

  Future<void> _fetchUserCropsAndStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _cropService.getUserCropsAndStats();

      setState(() {
        _userCrops = data['userCrops'] ?? [];
        _stats = data['stats'] ?? {};
        _userName = data['userName'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserCropsAndStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchUserCropsAndStats,
                  color: Colors.green,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildStatisticsSection(),
                          const SizedBox(height: 24),
                          _buildMyCropsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName.isNotEmpty ? _userName : 'Farmer Profile',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final currencyFormat =
        NumberFormat.currency(symbol: 'Rs', decimalDigits: 2, locale: 'si_LK');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.farm_statistics,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.total_crops,
                    '${_stats['totalCrops'] ?? 0}',
                    Icons.grass,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.total_quantity,
                    '${_stats['totalQuantity'] ?? 0} kg',
                    Icons.scale,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.total_value,
                    currencyFormat.format(_stats['totalValue'] ?? 0),
                    Icons.monetization_on,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.avg_price,
                    currencyFormat.format(_stats['averagePricePerUnit'] ?? 0),
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.active_crops,
                    '${_stats['activeCrops'] ?? 0}',
                    Icons.check_circle_outline,
                    Colors.teal,
                  ),
                ),
                Expanded(
                  child: _buildStatisticItem(
                    AppLocalizations.of(context)!.crops_with_interest,
                    '${_stats['bookedCrops'] ?? 0}',
                    Icons.shopping_cart,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMyCropsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Listed Crops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to a more detailed crop management page if needed
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Manage'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _userCrops.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.no_food,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You haven\'t listed any crops yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to list crop page
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('List a Crop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userCrops.length,
                itemBuilder: (context, index) {
                  final crop = _userCrops[index];
                  return _buildCropListItem(crop);
                },
              ),
      ],
    );
  }

  Widget _buildCropListItem(dynamic crop) {
    final NumberFormat currencyFormat =
        NumberFormat.currency(symbol: 'Rs', decimalDigits: 2, locale: 'si_LK');
    final String cropId = crop['id'] ?? ''; // Make sure you have the crop ID
    final String cropName = crop['cropName'] ?? 'Unknown Crop';
    final double price = (crop['price'] ?? 0).toDouble();
    final String location = crop['location'] ?? 'Unknown Location';
    final int quantity = crop['quantity'] ?? 0;
    final double cropValue = (crop['cropValue'] ?? 0).toDouble();
    final bool isBooked = crop['is_booked'] ?? false;
    final List<dynamic> imageUrls = crop['imageURLs'] ?? [];
    final String harvestDate = crop['harvestDate'] ?? '';
    final String description = crop['description'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateCropPage(
              cropId: cropId,
              initialCropName: cropName,
              initialDescription: description,
              initialPrice: price,
              initialLocation: location,
              initialQuantity: quantity,
              initialHarvestDate: harvestDate,
              initialImageUrls: imageUrls,
              onCropUpdated: _fetchUserCropsAndStats,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: imageUrls.isNotEmpty
                      ? Image.network(
                          imageUrls[0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'lib/assets/default_crop.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'lib/assets/default_crop.jpg',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Crop Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cropName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        isBooked
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Booked',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Available',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (harvestDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Harvested: $harvestDate',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currencyFormat.format(price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$quantity kg',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Value: ${currencyFormat.format(cropValue)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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
}
