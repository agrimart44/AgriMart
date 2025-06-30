
import 'package:flutter/material.dart';
import 'package:namer_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Language> _languages = [
    Language(name: 'English', code: 'en'),
    Language(name: 'සිංහල (Sri Lanka)', code: 'si'),
    Language(name: 'தமிழ்', code: 'ta'),
  ];

  List<Language> get _filteredLanguages => _languages
      .where((language) =>
      language.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/first_page_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.select_your_language,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),


                      // Language List
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredLanguages.length,
                          itemBuilder: (context, index) {
                            final language = _filteredLanguages[index];
                            final isSelected =
                            languageProvider.locale.languageCode  == language.code;

                            return ListTile(
                              title: Text(
                                language.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                                  : const Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                setState(() {
                                  languageProvider.setLocale(Locale(language.code));
                                });

                                // Show a snackbar or perform any action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selected language: ${language.name}',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class Language {
  final String name;
  final String code;

  Language({
    required this.name,
    required this.code,
  });
}

