import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';



enum Vegetable {
  carrot('Carrot'),
  tomato('Tomato'),
  potato('Potato'),
  cucumber('Cucumber'),
  spinach('Spinach');

  const Vegetable(this.label);
  final String label;
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

  @override
  void initState() {
    super.initState();
    selectedVegetable = Vegetable.potato; // Set initial selection to tomato
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
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the left
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),

         child:  Container(
          color: Colors.greenAccent,
        child:  IconButton(onPressed: () {
          print("Back Button Pressed");
           // Add your onPressed functionality here
         }, icon: Icon(Icons.chevron_left)
          ,color: Colors.white,
         ),

         
         ),
          ),
          
          const SizedBox(width: 190),
          IconButton(onPressed: (){
            print("Notification Button Pressed");
            

          }, icon: Icon(Icons.notifications),
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
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(width: 66),
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
                  child: Text(vegetable.label),
                );
              }).toList(),
              onChanged: (Vegetable? newValue) {
                setState(() {
                  selectedVegetable = newValue;
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
                "Rs.  175/Kg",
                style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHarvestSection3(BuildContext context) {
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
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            const SizedBox(width: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Rs.  185/Kg",
                style: TextStyle(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
            const SizedBox(width: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "High",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
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
                        spots: [
                          FlSpot(0, 80),
                          FlSpot(1, 120),
                          FlSpot(2, 100),
                          FlSpot(3, 150),
                          FlSpot(4, 130),
                          FlSpot(5, 110),
                          FlSpot(6, 90),
                        ],
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
