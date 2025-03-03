import 'package:flutter/material.dart';
import 'package:namer_app/Cart/shopping_cart_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
  
}

class _MyAppState extends State<MyApp> {
  int count = 0;
  Color _scaffoldColor = Colors.white;
  double _isVisible = 0.0;
  String _nameToChange = "flow";
  String _inputText = "";
  int _hours=0;
  final ScrollController _scrollController = ScrollController(); // Step 1: Declare ScrollController

  void numbers() {
    setState(() {
      count++;
    });
  }

  void changeColor() {
    setState(() {
      _scaffoldColor = _scaffoldColor == Colors.black12 ? Colors.blue : Colors.black12;
    });
  }

  void changeVisibility() {
    setState(() {
      _isVisible = _isVisible == 1.0 ? 0.0 : 1.0;
    });
  }

  void changeName() {
    setState(() {
      _nameToChange = _nameToChange == "flow" ? "rukaass" : "flow";
    });
  }
  void changeHour(){
    setState(() {
      _hours++;
      
      
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShoppingCartPage()
      );
    
  }
}
