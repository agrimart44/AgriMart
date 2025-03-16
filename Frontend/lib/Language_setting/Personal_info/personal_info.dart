import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: Locale("si"), // Manually set language
      supportedLocales: const [
        Locale('en'), // English
        Locale('si'), // Sinhala
        Locale('ta'), // Tamil
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // User-entered Data (Dynamic)
    String userName = "Saman";
    String userGender = "Male";
    String userRole = "Farmer";
    String userLocation = "Nuwara Eliya";

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'lib/assets/first_page_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Background Overlay
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8), // Transparent effect
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.personal_information,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Person Icon
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    userName, // No Translation Needed
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  userInfo(Icons.person, AppLocalizations.of(context)!.full_name, userName),
                  userInfo(Icons.male, AppLocalizations.of(context)!.gender, userGender),
                  userInfo(Icons.work, AppLocalizations.of(context)!.role, userRole),
                  userInfo(Icons.location_on, AppLocalizations.of(context)!.location, userLocation),
                ],
              ),
            ),
          ),

          // Back Button Arrow
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Add navigation back logic here
              },
            ),
          ),
        ],
      ),
    );
  }
}

// User Info Widget (No Translation for Values)
Widget userInfo(IconData icon, String title, String value) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 5),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Text(
          "$title: ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    ),
  );
}
