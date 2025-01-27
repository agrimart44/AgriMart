import 'package:flutter/material.dart';

class PriceAnalysis extends StatelessWidget {
  const PriceAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
         
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
          
            child: Column(
              

              
              children: [
               
                
                // // Header Section
                // Text(
                 

                //   "Market Price Analysis",
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.yellow,
                //   ),
                 
                // ),
                // const SizedBox(width: 20),

                //  Text(
                //   "Market Price Analysis",
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.blue,
                //   ),
                //   // textAlign: TextAlign.center,
                // ),

                  


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

                // Authentication Buttons Section
                // const Spacer(),
                // _buildAuthenticationButtons(context),
              ],
            ),
          ),
        ),
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
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),
               const SizedBox(width: 30),


         Align(
            alignment: Alignment.centerLeft,
          
             child: Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),

        ],
      ),
  
    );
  }





   Widget _buildPostHarvestSection2(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft, // Aligns container to the left
   child:  Container(
    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
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
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),
               const SizedBox(width: 30),


        Align(
            alignment: Alignment.centerLeft,
          
             child: Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),

        ],
      ),
  
    ),
    );
  }

Widget _buildPostHarvestSection3(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft, // Aligns container to the left
   child:  Container(
    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
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
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),
               const SizedBox(width: 30),


         Align(
            alignment: Alignment.centerLeft,
          
             child: Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),

        ],
      ),
  
    ),
    );
  }


  Widget _buildPostHarvestSection4(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft, // Aligns container to the left
   child:  Container(
    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
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
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),
               const SizedBox(width: 30),


        Align(
            alignment: Alignment.centerLeft,
          
             child: Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),

        ],
      
      ),
  
    ),
    );
  }


  Widget _buildPostHarvestSection5(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft, // Aligns container to the left
   child:  Container(
    width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
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
        "Price Analysis",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),
               const SizedBox(width: 30),


        Align(
            alignment: Alignment.centerLeft,
          
             child: Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
          ),

        ],
      
      ),
  
    ),
    );
  }





  // Widget _buildAuthenticationButtons(BuildContext context) {
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     ElevatedButton(
    //       onPressed: () {
    //         // Login action
    //       },
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.green,
    //         foregroundColor: Colors.white,
    //         minimumSize: const Size(260, 50),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //       ),
    //       child: const Text("Login"),
    //     ),
    //     const SizedBox(height: 20),
    //     ElevatedButton(
    //       onPressed: () {
    //         // Sign-up action
    //       },
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.green,
    //         foregroundColor: Colors.white,
    //         minimumSize: const Size(260, 50),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(8),
    //         ),
    //       ),
    //       child: const Text("Sign Up"),
    //     ),
    //   ],
    // );
  
}
