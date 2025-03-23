import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:intl/intl.dart'; // Import intl package

enum Vegetable {
   carrot('Carrot', 'lib/assets/carrot.jpg'),
  tomato('Tomato', 'lib/assets/tomato.jpg'),
  pumpkin('Pumpkin', 'lib/assets/pumpkin.jpg'),
  lime('Lime', 'lib/assets/lime.jpg'),
  cabbage('Cabbage', 'lib/assets/lime.jpg'),
  brinjal('Brinjal', 'lib/assets/lime.jpg'),
  // ignore: constant_identifier_names
  Snakegourd('Snake gourd', 'lib/assets/lime.jpg'),
  // ignore: constant_identifier_names
  GreenChilli('Green Chilli', 'lib/assets/lime.jpg');


  const Vegetable(this.label, this.imagePath);
  final String label;
  final String imagePath;
}

class VegetableAnalysisScreen extends StatefulWidget {
  @override
  _VegetableAnalysisScreenState createState() => _VegetableAnalysisScreenState();
}

class _VegetableAnalysisScreenState extends State<VegetableAnalysisScreen> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController vegetableController = TextEditingController();
  Vegetable? selectedVegetable;
  List<double> priceData = []; // Define priceData variable
  List<double> currentData = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double? _selectedDayPrice;
  double? latestCurrentPrice;
  double? latestPredictedPrice;

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
            latestPredictedPrice = priceData.isNotEmpty ? priceData.last : null;
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
            latestCurrentPrice = currentData.isNotEmpty ? currentData.last : null;
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
      final DateTime today = DateTime.now();
      final String formattedToday = DateFormat('yyyy-MM-dd').format(today);

      if (formattedDay == formattedToday) {
        // Fetch current price
        if (currentData.isNotEmpty) {
          setState(() {
            _selectedDayPrice = currentData.last;
          });
          print('Current price for selected day: $_selectedDayPrice');
          _showPriceDialog(formattedDay, _selectedDayPrice, isCurrentPrice: true);
        } else {
          setState(() {
            _selectedDayPrice = null;
          });
          print('No current price found for selected day');
          _showPriceDialog(formattedDay, null, isCurrentPrice: true);
        }
      } else {
        // Fetch predicted price
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
                  latestPredictedPrice = _selectedDayPrice; // Update the predicted price for the selected date
                });
                print('Predicted price for selected day: $_selectedDayPrice');
                _showPriceDialog(formattedDay, _selectedDayPrice, isCurrentPrice: false);
                return;
              }
            }

            setState(() {
              _selectedDayPrice = null;
            });
            print('No predicted price found for selected day');
            _showPriceDialog(formattedDay, null, isCurrentPrice: false);
          } else {
            print('No predictions found');
          }
        } else {
          print('Document does not exist');
        }
      }
    } catch (e) {
      print('Error fetching price for selected day: $e');
    }
  }

  void _showPriceDialog(String formattedDay, double? price, {required bool isCurrentPrice}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text(
                isCurrentPrice ? "Current Price" : "How it will change?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                price != null ? " 🤔" : " 🤔",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                price != null ? Icons.check_circle : Icons.error,
                color: price != null ? Colors.green : Colors.red,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                price != null
                    ? "${isCurrentPrice ? "Current" : "Predicted"} Price: Rs. ${price.toStringAsFixed(2)} per/Kg"
                    : "No price available for $formattedDay",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostHarvestSection4(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  Text(
    "Market Demand",
    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 10),
  Text(
    (priceData.isNotEmpty && currentData.isNotEmpty && priceData.last > currentData.last)
        ? "Demand is High"
        : "Demand is Low",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: (priceData.isNotEmpty && currentData.isNotEmpty && priceData.last > currentData.last)
          ? Colors.green.shade900 // Green for high demand
          : Colors.red.shade900,   // Red for low demand
        ),
      ),
    ],

          ),
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection5(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Price Trends",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            color: Colors.green.shade900,
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
                            color: Colors.green.shade600,
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
                            title: (priceData.isNotEmpty && currentData.isNotEmpty && (priceData.last - currentData.last).abs() > 20) ? "Change" : "",
                            color: Colors.green.shade300,
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
                  _buildLegendItem(Colors.green.shade900, 'Predicted Price'),
                  _buildLegendItem(Colors.green.shade600, 'Current Price'),
                  _buildLegendItem(Colors.green.shade300, 'Change'),
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

Widget _buildPostHarvestSection(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.8), // Slightly transparent white background
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Select Vegetable",
            style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 25),
        Flexible(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
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
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vegetable Analysis"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Enhanced Dropdown Card
              _buildPostHarvestSection(context),
              SizedBox(height: 10),

              // Price Section
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Price",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        Text(
                          latestCurrentPrice != null
                              ? "Rs. ${latestCurrentPrice!.toStringAsFixed(2)} /Kg"
                              : "Loading...",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text("Predicted Price",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        Text(
                          latestPredictedPrice != null
                              ? "Rs. ${latestPredictedPrice!.toStringAsFixed(2)} /Kg"
                              : "Loading...",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Calendar Section
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select date to view price",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(Duration(days: 27)),
                          focusedDay: _focusedDay,
                          calendarFormat: CalendarFormat.month,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          selectedDayPredicate: (day) {
                            return isSameDay(day, _selectedDay);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              String formattedDay = DateFormat('yyyy-MM-dd').format(selectedDay);
                              fetchPriceForSelectedDay(selectedVegetable!.label, formattedDay);
                            });
                          },
                          calendarBuilders: CalendarBuilders(
                            todayBuilder: (context, date, _) {
                              return Center(
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade800,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                            selectedBuilder: (context, date, _) {
                              return Center(
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          availableGestures: AvailableGestures.all,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Market Demand Section
              _buildPostHarvestSection4(context),
              SizedBox(height: 10),

              // Enhanced Pie Chart Section
              _buildPostHarvestSection5(context),
            ],
          ),
        ),
      ),
    );
  }
}
