class Crop {
  final String id;
  final String name;
  final String description;
  final double price;
  final String location;
  final String category;
  final String farmerName;
  final String contactNumber;
  final DateTime harvestDate;
  final List<String> imagePaths;
  final double rating;
  final int quantity; // Added quantity field

  Crop({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.location,
    required this.category,
    required this.farmerName,
    required this.contactNumber,
    required this.harvestDate,
    required this.imagePaths,
    required this.rating,
    required this.quantity, // Added quantity parameter
  });
}