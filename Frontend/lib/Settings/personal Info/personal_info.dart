
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children:[
          //background
          Positioned.fill(child:Image.asset('lib/assets/first_page_background.jpg',fit: BoxFit.cover,
          ),
          ),
          // background-overlay
          Center(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8), // Transparent effect
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, children: [
                    Text("Personal Information",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color:Colors.white,),
                    ),
                    SizedBox(height: 20),
                    //person icon
                    CircleAvatar(radius: 40,backgroundColor:Colors.white,child: Icon(Icons.person,size:50,color: Colors.grey,),
                    ),
                    SizedBox(height: 10),
                    Text("Rathnayake",style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // user informations like name,gender,location...
                    userInfo(Icons.person,"Full Name" , "Rathnayake"),
                    userInfo(Icons.male,"Gender" , "Male"),
                    userInfo(Icons.work,"Farmer/Buyer" , "Farmer"),
                    userInfo(Icons.location_on,"Location" , "Nuwara Eliya"),
                  ],
                ),
            ),
          )
        ],
      ),
    );
  }
}