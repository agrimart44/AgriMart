import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

enum Vegetable {
  carrot('Carrot', 'lib/assets/first_page_background.jpg'),
  tomato('Tomato', 'lib/assets/first_page_background.jpg'),
  snakeGourd('Snake-gourd', 'lib/assets/first_page_background.jpg'),
  pumpkin('Pumpkin', 'lib/assets/first_page_background.jpg'),
  lime('Lime', 'lib/assets/first_page_background.jpg');

  const Vegetable(this.label, this.imagePath);
  final String label;
  final String imagePath;
}

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController vegetableController = TextEditingController();
  Vegetable? selectedVegetable;
  List<double> priceData = []; // Define priceData variable
  List<double> currentData = [];

  @override
  void initState() {
    super.initState();
    selectedVegetable = Vegetable.carrot; // Set initial selection to carrot
    _initializeFirebase(); // Initialize Firebase
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('Firebase initialized successfully');
      await fetchPriceData(selectedVegetable!.label); // Fetch initial data
      await fetchPriceData2(selectedVegetable!.label); // Fetch current data
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
   
  Future<void> fetchPriceData(String vegetable) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("predictions_for_next_days")
          .doc(vegetable)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        if (data != null && data.containsKey('predictions_for_next_days')) {
          final List<dynamic> predictions = data['predictions_for_next_days'];

          List<Map<String, dynamic>> formattedData = predictions.map((entry) {
            return {
              "date": entry["date"],
              "Price": entry["Price"],
            };
          }).toList();

          setState(() {
            priceData = formattedData.map((entry) => entry["Price"] as double).toList();
          });

          print('Fetched Predictions: $formattedData');
        } else {
          print('No predictions found');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchPriceData2(String vegetable) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("predictions_updated_for_current")
          .doc(vegetable)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        if (data != null && data.containsKey('predictions_updated_for_current')) {
          final List<dynamic> predictions = data['predictions_updated_for_current'];

          List<Map<String, dynamic>> formattedData = predictions.map((entry) {
            return {
              "date": entry["date"],
              "Price": entry["Price"],
            };
          }).toList();

          setState(() {
            currentData = formattedData.map((entry) => entry["Price"] as double).toList();
          });

          print('Fetched Predictions: $formattedData');
        } else {
          print('No predictions found');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostHarvestSection0(context),
                  const SizedBox(height: 30),

                  // Post-Harvest Section
                  _buildPostHarvestSection(context),
                  const SizedBox(height: 30),

                  _buildPostHarvestSection2(context),
                  const SizedBox(height: 30),

                  _buildPostHarvestSection3(context),
                  const SizedBox(height: 30),

                  _buildPostHarvestSection4(context),
                  const SizedBox(height: 30),

                  _buildPostHarvestSection5(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection0(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              color: Colors.greenAccent,
              child: IconButton(
                onPressed: () {
                  print("Back Button Pressed");
                  // Add your onPressed functionality here
                },
                icon: Icon(Icons.chevron_left),
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 190),
          IconButton(
            onPressed: () {
              print("Notification Button Pressed");
            },
            icon: Icon(Icons.notifications),
            color: Colors.greenAccent,
            iconSize: 30,
          ),
          const SizedBox(width: 5),
          Container(
            color: Colors.white,
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () {
                print("Profile Button Pressed");
              },
              icon: Icon(Icons.menu),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHarvestSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Market Price Analysis",
              style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 25),
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<Vegetable>(
              iconEnabledColor: Colors.blue,
              focusColor: Colors.red,
              value: selectedVegetable,
              dropdownColor: Colors.white, // Set the background color of the dropdown menu to white
              items: Vegetable.values.map((Vegetable vegetable) {
                return DropdownMenuItem<Vegetable>(
                  value: vegetable,
                  child: Row(
                    children: [
                      Image.asset(
                        vegetable.imagePath,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(vegetable.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (Vegetable? newValue) {
                setState(() {
                  selectedVegetable = newValue;
                  fetchPriceData(selectedVegetable!.label); // Fetch data when selection changes
                  fetchPriceData2(selectedVegetable!.label); // Fetch current data when selection changes
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHarvestSection2(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Current Price",
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            const SizedBox(width: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentData.isNotEmpty ? "Rs. ${currentData.last.toStringAsFixed(2)}/Kg" : 'not available',
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection3(BuildContext context) {
    print("Selected Vegetable: $selectedVegetable");
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Predicted Price",
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            const SizedBox(width: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                priceData.isNotEmpty ? "Rs. ${priceData.last.toStringAsFixed(2)}/Kg" : 'not available',
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection4(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Market Demand",
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            const SizedBox(width: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (priceData.isNotEmpty && currentData.isNotEmpty && priceData.last > currentData.last) ? "Demand is High" : "Demand is Low",
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection5(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        //  height: MediaQuery.of(context).size.height * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Price Trends",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Adding the Line Chart Below
              SizedBox(
                height: 180, // Height of the chart
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: priceData
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                            .toList(),
                        isCurved: true,
                        barWidth: 4,
                        color: Colors.green,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
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
