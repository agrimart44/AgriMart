import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'package:intl/intl.dart'; // Import intl package

enum Vegetable {
  carrot('Carrot', 'lib/assets/carrot.jpg'),
  tomato('Tomato', 'lib/assets/tomato.jpg'),
  pumpkin('Pumpkin', 'lib/assets/pumpkin.jpg'),
  lime('Lime', 'lib/assets/lime.jpg');

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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double? _selectedDayPrice;

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

  Future<void> fetchPriceForSelectedDay(String vegetable, String formattedDay) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("predictions_for_next_days")
          .doc(vegetable)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();

        if (data != null && data.containsKey('predictions_for_next_days')) {
          final List<dynamic> predictions = data['predictions_for_next_days'];

          for (var entry in predictions) {
            if (entry["date"] == formattedDay) {
              setState(() {
                _selectedDayPrice = entry["Price"];
              });
              print('Price for selected day: $_selectedDayPrice');
              return;
            }
          }

          setState(() {
            _selectedDayPrice = null;
          });
          print('No price found for selected day');
        } else {
          print('No predictions found');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching price for selected day: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Helvetica Neue', // Set the default font family to SF Pro Text
        primarySwatch: Colors.red,
      ),
      home: SafeArea(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: double.infinity,
            color: Color(0xFFCBE54E), // Solid background color
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
      ),
    );
  }

  Widget _buildPostHarvestSection0(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Slightly transparent white background
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle, // Make the container circular
                ),
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
            const SizedBox(width: 150),
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
      ),
    );
  }

  Widget _buildPostHarvestSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Slightly transparent white background
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Vegetable Analysis",
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
          color: Colors.white.withOpacity(0.8), // Slightly transparent white background
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
          color: Colors.white.withOpacity(0.8), // Slightly transparent white background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  selectedVegetable!.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Predicted Price",
                    style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 28)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay; // update `_focusedDay` here as well
                      String formattedDay = DateFormat('yyyy-MM-dd').format(selectedDay);
                      fetchPriceForSelectedDay(selectedVegetable!.label, formattedDay);
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedDayPrice != null)
                  Text(
                    "Price: Rs. ${_selectedDayPrice!.toStringAsFixed(2)}/Kg for vegetable ${selectedVegetable!.label}", 
                    style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    "No price available for the ${DateFormat('yyyy-MM-dd').format(_selectedDay!)}",
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
              ],
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
          color: Colors.white.withOpacity(0.8), // Slightly transparent white background
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
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // Slightly transparent white background
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
            
            // Adding the Enhanced Pie Chart Below
            SizedBox(
              height: 290, // Increased height for better visibility
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: priceData.isNotEmpty ? priceData.last : 0,
                          color: Colors.green,
                          title: 'Predicted',
                          radius: 80, // Increased radius
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: currentData.isNotEmpty ? currentData.last : 0,
                          color: Colors.red,
                          title: 'Current',
                          radius: 80, // Increased radius
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: priceData.isNotEmpty && currentData.isNotEmpty
                              ? (priceData.last - currentData.last).abs()
                              : 0,
                          title: (priceData.isNotEmpty && currentData.isNotEmpty && (priceData.last - currentData.last).abs() > 20) ? "Difference" : "",
                          color: Colors.blue,
                          radius: 80, // Increased radius
                          titleStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      sectionsSpace: 8, // Space between sections
                      centerSpaceRadius: 60, // Larger center space
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (pieTouchResponse?.touchedSection != null) {
                            print('Touched Section Index: ${pieTouchResponse?.touchedSection!.touchedSectionIndex}');
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Price\nBreakdown",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Legend Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Colors.green, 'Predicted Price'),
                _buildLegendItem(Colors.red, 'Current Price'),
                _buildLegendItem(Colors.blue, 'Gap'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper method to build legend items
Widget _buildLegendItem(Color color, String label) {
  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
}
