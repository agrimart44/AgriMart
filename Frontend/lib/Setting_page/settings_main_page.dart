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
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSettingsOption(context, 'Personal Information', 'Your account information'),
                const SizedBox(height: 15),
                _buildSettingsOption(context, 'Password and Account', 'Your account security settings'),
                const SizedBox(height: 15),
                _buildSettingsOption(context, 'Language Settings', 'Change your preferred language'),
                const SizedBox(height: 15),
                _buildSettingsOption(context, 'Privacy & Security', 'Manage your privacy settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        // TODO: Implement navigation to respective settings pages
        print('Navigating to $title');
      },
    );
  }
}



