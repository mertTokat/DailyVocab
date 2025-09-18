import 'package:flutter/material.dart';
import 'word_data.dart';

class SettingsPage extends StatelessWidget {
  final Language selectedLanguage;
  const SettingsPage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Turkish'),
            leading: Radio<Language>(
              value: Language.turkish,
              groupValue: selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
          ),
          ListTile(
            title: const Text('Chinese'),
            leading: Radio<Language>(
              value: Language.chinese,
              groupValue: selectedLanguage,
              onChanged: (value) {
                Navigator.pop(context, value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
