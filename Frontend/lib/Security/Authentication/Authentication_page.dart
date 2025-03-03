import 'package:flutter/material.dart';

void main() {
    runApp(SecurityScreen());
}

class SecurityScreen extends StatelessWidget {
    SecurityScreen({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                body: Stack(
                children: [
        Container(
                decoration: const BoxDecoration(
                image: DecorationImage(
                image:
        AssetImage("assets/background.jpg"), // Background image
                fit: BoxFit.cover,
                ),
              ),
            ),
        SafeArea(
                child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
        IconButton(
                icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
        style: IconButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                "Add extra security to your account",
                style:
        TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                "Two - factor authentication protects your account by requiring an additional code when you log in on a device that we don't recognize.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    
                    const SizedBox(height: 20),
                    const Text(
                "Choose your security method",
                style:
        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                  const SizedBox(height: 20),
          buildSecurityMethod(
            'Authentication app',
            'We\'ll recommend an app to download if you don\'t have one. It will send a code that you\'ll enter when you login',
            isRecommended: true,
            isSelected: true,
            ),

                const SizedBox(height: 20),
            buildSecurityMethod(
            'SMS or WhatsApp',
            'We\'ll send a code to the mobile number that we have on file for your account',
            isSelected: false,
          ),

        // next
        const SizedBox(height: 200),

          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                
              
              child: const Text(
                "Next",
                style: TextStyle(fontSize: 16, color: Colors.white),
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
      ),
    );
  }

            

                  
    Widget buildListTile(String title) {
        return ListTile(
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
    );
    }
}




Widget buildSecurityMethod(String title, String description, 
      {bool isRecommended = false, bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Radio(
            value: isSelected,
            groupValue: true,
            activeColor: Colors.green,
            onChanged: null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




