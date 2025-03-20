import 'package:flutter/material.dart';
import 'package:namer_app/Settings/language_settings.dart';
import 'package:namer_app/personal%20Info/personal_info.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  AppSettingsState createState() => AppSettingsState();
}

class AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light gray background instead of image
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: Colors.green[700]),
            onPressed: () {
              print('Show notifications');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // User profile header
              // Container(
              //   margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              //   padding: const EdgeInsets.all(20),
              //   decoration: BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Colors.green.shade50, Colors.green.shade100],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: BorderRadius.circular(20),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.green.withOpacity(0.1),
              //         blurRadius: 10,
              //         offset: const Offset(0, 4),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 70,
              //         height: 70,
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           shape: BoxShape.circle,
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.1),
              //               blurRadius: 8,
              //               offset: const Offset(0, 3),
              //             ),
              //           ],
              //         ),
              //         child: Icon(
              //           Icons.person,
              //           size: 36,
              //           color: Colors.green[700],
              //         ),
              //       ),
              //       const SizedBox(width: 16),
              //       // Expanded(
              //       //   child: Column(
              //       //     crossAxisAlignment: CrossAxisAlignment.start,
              //       //     children: [
              //       //       Text(
              //       //         "John Smith",
              //       //         style: TextStyle(
              //       //           fontSize: 20,
              //       //           fontWeight: FontWeight.bold,
              //       //           color: Colors.green[800],
              //       //         ),
              //       //       ),
              //       //       const SizedBox(height: 4),
              //       //       Text(
              //       //         "Farmer",
              //       //         style: TextStyle(
              //       //           fontSize: 16,
              //       //           color: Colors.green[700],
              //       //         ),
              //       //       ),
              //       //       const SizedBox(height: 2),
              //       //       Text(
              //       //         "john.smith@example.com",
              //       //         style: TextStyle(
              //       //           fontSize: 14,
              //       //           color: Colors.grey[700],
              //       //         ),
              //       //       ),
              //       //     ],
              //       //   ),
              //       // ),
              //       // IconButton(
              //       //   icon: Icon(
              //       //     Icons.edit_outlined,
              //       //     color: Colors.green[700],
              //       //   ),
              //       //   onPressed: () {
              //       //     Navigator.push(
              //       //       context,
              //       //       MaterialPageRoute(
              //       //         builder: (context) => const PersonalInformation(),
              //       //       ),
              //       //     );
              //       //   },
              //       // ),
              //     ],
              //   ),
              // ),
              
              // Section header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Settings options
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModernSettingsCard(
                      context,
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      subtitle: 'Manage your profile details',
                      iconBgColor: Colors.blue.shade50,
                      iconColor: Colors.blue.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalInformation(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildModernSettingsCard(
                      context,
                      icon: Icons.language,
                      title: 'Language Settings',
                      subtitle: 'Choose your preferred language',
                      iconBgColor: Colors.purple.shade50,
                      iconColor: Colors.purple.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSettingsPage(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildModernSettingsCard(
                      context,
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your privacy preferences',
                      iconBgColor: Colors.amber.shade50,
                      iconColor: Colors.amber.shade700,
                      onTap: () {
                        print('Navigate to Privacy & Security');
                      },
                    ),
                  ],
                ),
              ),
              
              // Help & Support section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 20,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Help & Support",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildModernSettingsCard(
                      context,
                      icon: Icons.feedback_outlined,
                      title: 'Feedback',
                      subtitle: 'Help us improve AgriMart',
                      iconBgColor: Colors.indigo.shade50,
                      iconColor: Colors.indigo.shade700,
                      onTap: () {
                        // Handle feedback
                      },
                    ),
                  ],
                ),
              ),
              
              // Sign Out Button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                child: ElevatedButton(
                  onPressed: () {
                    print('Sign out pressed');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red[700],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // App version info
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    "AgriMart v1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Container(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildModernSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
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
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
