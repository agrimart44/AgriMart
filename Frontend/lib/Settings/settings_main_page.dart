import 'package:flutter/material.dart';
import 'package:namer_app/Settings/language_settings.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:namer_app/personal_Info/personal_info.dart';

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
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),        
      ),


      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //gape between settings header and options
              Container(
                margin: const EdgeInsets.fromLTRB(16, 25, 20, 0), // Added top margin
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
                      title: AppLocalizations.of(context)!.personal_information,
                      subtitle: 'Manage your profile details',
                      iconBgColor: Colors.green.shade50,
                      iconColor: Colors.green.shade700,
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
                      title: AppLocalizations.of(context)!.language_settings,
                      subtitle: 'Choose your preferred language',
                      iconBgColor: Colors.green.shade50,
                      iconColor: Colors.green.shade700,
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
                      title: AppLocalizations.of(context)!.privacy_policy,
                      subtitle: 'Manage your privacy preferences',
                      iconBgColor: Colors.green.shade50,
                      iconColor: Colors.green.shade700,
                      onTap: () {
                        print('Navigate to Privacy & Security');
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
