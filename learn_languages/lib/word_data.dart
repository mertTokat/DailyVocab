import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum Language { turkish, chinese }

Future<Map<String, List<Map<String, dynamic>>>> loadWords(Language language) async {
  final levels = language == Language.turkish
      ? {
          'Beginner': 'assets/output_1.json',
          'Intermediate': 'assets/output_2.json',
          'Advanced': 'assets/output_3.json',
        }
      : {
          'HSK1': 'assets/hsk1_full.json',
          // Add more levels/files for Chinese if available
        };
  Map<String, List<Map<String, dynamic>>> data = {};
  for (final entry in levels.entries) {
    final jsonStr = await rootBundle.loadString(entry.value);
    final List<dynamic> jsonList = json.decode(jsonStr);
    data[entry.key] = jsonList.cast<Map<String, dynamic>>();
  }
  return data;
}
