import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';

class MapLocationPicker extends StatefulWidget {
  final String? initialLocation;
  
  const MapLocationPicker({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  final loc.Location _location = loc.Location();
  LatLng _selectedPosition = const LatLng(7.8731, 80.7718); // Default to Sri Lanka center
  String _selectedAddress = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }
  
  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if initial location was provided
      if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
        await _getLocationFromAddress(widget.initialLocation!);
      } else {
        // Get current user location
        bool serviceEnabled = await _location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await _location.requestService();
          if (!serviceEnabled) {
            return;
          }
        }
        
        loc.PermissionStatus permissionGranted = await _location.hasPermission();
        if (permissionGranted == loc.PermissionStatus.denied) {
          permissionGranted = await _location.requestPermission();
          if (permissionGranted != loc.PermissionStatus.granted) {
            return;
          }
        }
        
        loc.LocationData locationData = await _location.getLocation();
        _selectedPosition = LatLng(locationData.latitude!, locationData.longitude!);
        await _getAddressFromLatLng(_selectedPosition);
      }
      
      // Animate to the selected position
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedPosition,
          zoom: 14.0,
        ),
      ));
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          _selectedAddress = _selectedAddress.replaceAll(RegExp(r', ,'), ',');
          _selectedAddress = _selectedAddress.replaceAll(RegExp(r'^, |, $'), '');
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Address not found';
      });
    }
  }
  
  Future<void> _getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedPosition = LatLng(locations[0].latitude, locations[0].longitude);
          _selectedAddress = address;
        });
      }
    } catch (e) {
      // If geocoding fails, use default location
      setState(() {
        _selectedAddress = 'Location not found';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng position) async {
              setState(() {
                _selectedPosition = position;
                _isLoading = true;
              });
              await _getAddressFromLatLng(position);
              setState(() {
                _isLoading = false;
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selectedLocation'),
                position: _selectedPosition,
                draggable: true,
                onDragEnd: (LatLng position) async {
                  setState(() {
                    _selectedPosition = position;
                    _isLoading = true;
                  });
                  await _getAddressFromLatLng(position);
                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            },
          ),
          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.green),
                    onPressed: _initializeLocation,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    setState(() {
                      _isLoading = true;
                    });
                    await _getLocationFromAddress(value);
                    final GoogleMapController controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _selectedPosition,
                        zoom: 14.0,
                      ),
                    ));
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
          ),
          // Selected location info and confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selected Location:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.green))
                      : Text(
                          _selectedAddress,
                          style: const TextStyle(fontSize: 14),
                        ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Coordinates: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        // Return location data to previous screen
                        Navigator.pop(context, {
                          'address': _selectedAddress,
                          'latitude': _selectedPosition.latitude,
                          'longitude': _selectedPosition.longitude,
                        });
                      },
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}