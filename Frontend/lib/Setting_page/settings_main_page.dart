 import 'package:flutter/material.dart';


class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'App Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'lib/assets/first_page_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // The content of the settings screen
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.grey[350],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSettingsCard(
                            context,
                            icon: Icons.person_outline,
                            title: 'Personal Information',
                            subtitle: 'Your account information',
                            onTap: () {
                              // TODO: Navigate to Personal Information page
                              print('Navigate to Personal Information');
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildSettingsCard(
                            context,
                            icon: Icons.lock_outline,
                            title: 'Password and account',
                            subtitle: 'Your account information',
                            onTap: () {
                              // TODO: Navigate to Password and account page
                              print('Navigate to Password and account');
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildSettingsCard(
                            context,
                            icon: Icons.language,
                            title: 'Language Settings',
                            subtitle: 'Change your language here',
                            onTap: () {
                              // TODO: Navigate to Language Settings page
                              print('Navigate to Language Settings');
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildSettingsCard(
                            context,
                            icon: Icons.security,
                            title: 'Privacy & Security',
                            subtitle: 'Change your privacy & security settings',
                            onTap: () {
                              // TODO: Navigate to Privacy & Security page
                              print('Navigate to Privacy & Security');
                            },
                          ),
                          const SizedBox(height: 30), // Space between settings and sign-out button
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement sign out functionality
                                  print('Sign out pressed');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Sign out',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}






