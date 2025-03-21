import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:namer_app/Presentation/first_screen/Login.dart';
import 'package:namer_app/Presentation/registerpage/registerpageService.dart';
// Import the service file

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(); // Add location controller
  String? _selectedOccupation;
  bool _isLoading = false;

  final List<String> _occupations = [
    'Farmer',
    'Buyer',
  ];

  // Function to handle registration
Future<void> _registerUser() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await RegistrationService.registerUser(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phoneNumber: _phoneNumberController.text,
        occupation: _selectedOccupation ?? '',
        location: _locationController.text,
      );

      setState(() {
        _isLoading = false;
      });

      // If registration was successful, show dialog instead of SnackBar
      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false, // User must tap button to close dialog
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration Successful'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Your account has been created successfully!'),
                    SizedBox(height: 10),
                    Text('You can now log in using your email and password.'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Login Now'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: Colors.white,
              elevation: 5,
            );
          },
        );
      } else {
        // Show error SnackBar if registration failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
    backgroundColor: Colors.transparent, // Make AppBar background transparent
    elevation: 0, // Remove shadow
    title: Text(
     " " , // Set the dynamic title
      style: TextStyle(
        color: Colors.black, // Set text color to black
        fontWeight: FontWeight.bold,
      ),
    ),
    
  ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/first_page_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // Registration Form
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Hello! Register Here in',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Agri MART',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Username Field
                  _buildDarkInputField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter username' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildDarkInputField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Enter email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value!)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildDarkInputField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Enter password';
                      if (value!.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildDarkInputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    icon: Icons.lock_reset,
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Confirm password';
                      if (value != _passwordController.text) {
                        return 'Passwords mismatch';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  _buildDarkInputField(
                    controller: _phoneNumberController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Enter phone number';
                      if (!RegExp(r'^0\d{9}$').hasMatch(value!)) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location Field (Added as required by your API)
                  _buildDarkInputField(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Enter location' : null,
                  ),
                  const SizedBox(height: 16),

                  // Occupation Dropdown with dark background
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Select Your Occupation',
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.work_outline,
                            color: Colors.white70),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: _selectedOccupation,
                          dropdownColor: Colors.black87,
                          items: _occupations
                              .map((occupation) => DropdownMenuItem(
                                    value: occupation,
                                    child: Text(
                                      occupation,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedOccupation = value),
                          validator: (value) =>
                              value == null ? 'Select occupation' : null,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          hint: const Text(
                            'Choose occupation',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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

  Widget _buildDarkInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon, color: Colors.white70),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }
}