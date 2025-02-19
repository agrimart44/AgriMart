import 'package:flutter/material.dart';

class ListCropScreen extends StatefulWidget {
  const ListCropScreen({super.key});

  @override
  State<ListCropScreen> createState() => _ListCropScreenState();
}

class _ListCropScreenState extends State<ListCropScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Crop'),
      ),
      body: Center(
        child: Text('List Crop'),
      ),
    );
  }
}
