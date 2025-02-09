import 'package:flutter/material.dart';

import 'Login.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            
            color: Color.fromARGB(255, 255, 255, 255) ,
            image: DecorationImage(image: 
            AssetImage('lib/assets/first_page_background.jpg'),
            fit: BoxFit.cover

            )
            
            


            // Ensure appTheme is defined
            // image: DecorationImage(
            //   image: AssetImage(ImageConstant.imgFirst), // Ensure ImageConstant is imported
            //   fit: BoxFit.fill,
            // ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical:50), // Ensure h extension is defined
            child: Column(
              children: [
               
                Spacer(flex: 57),
                _builtAuthenticationButtons(context), // Add comma to fix syntax
                Spacer(flex: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _builtPostHarvestSection(BuildContext context) {
  //   // Implement your logic here
  //   return Container(
  //     // Example content for post-harvest section
  //     child: Text("Post-Harvest Section", style: TextStyle(fontSize: 20,color:Color.fromARGB(255, 255, 255, 255))),
  //   );
  // }

  

  Widget _builtAuthenticationButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
         Text("Post-Harvest Farmer -Buyer Connection Network Connection", style: TextStyle(fontSize: 20,color:Color.fromARGB(255, 255, 255, 255)),textAlign:TextAlign.center,),
         SizedBox(height: 260,),


        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },


          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            textStyle: TextStyle(color: Colors.white),
            foregroundColor: Colors.white,
            minimumSize: Size(260, 50),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
          ),
            
          ),
          child: Text("Login"),
        ),
        SizedBox(width: 60,height: 10,),

        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            
            backgroundColor: Colors.green,
            

            
            
            textStyle:TextStyle(color: Colors.white),
            foregroundColor: Colors.white,
            minimumSize: Size(260, 50),
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Reduce corner radius
          ),
             // Text color

          ),
          child: Text("Sign Up")
          ,
        ),
      ],
    );
  }
}
