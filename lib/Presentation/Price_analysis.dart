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
             Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
      
             ),
               const SizedBox(width: 30),


          Text(
        "Post-Harvest Section",
        style: TextStyle(fontSize: 12, color: Colors.black),
     
      ),

        ],
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
