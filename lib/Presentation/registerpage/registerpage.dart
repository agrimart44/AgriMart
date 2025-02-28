import 'dart:ui';
import 'package:flutter/material.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedOccupation;

  final List<String> _occupations = [
    'Farmer',
    'Buyer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      if (value!.length < 6) return 'Minimum 6 characters';
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle registration logic
                        }
                      },
                      child: const Text(
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
