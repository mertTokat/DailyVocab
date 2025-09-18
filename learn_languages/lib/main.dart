import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'settings_page.dart';
import 'word_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  final notifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await notifications.initialize(initSettings);
  runApp(MyApp(notifications: notifications));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin notifications;
  const MyApp({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Languages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 173, 216, 230)),
      ),
      home: MyHomePage(title: 'Learn Languages', notifications: notifications),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final FlutterLocalNotificationsPlugin notifications;
  const MyHomePage({super.key, required this.title, required this.notifications});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Language { turkish, chinese }

class _MyHomePageState extends State<MyHomePage> {
  Language _selectedLanguage = Language.turkish;
  Map<String, List<Map<String, dynamic>>> wordsByLevel = {};
  String _selectedLevel = '';
  int _wordIndex = 0;
  bool _loading = true;

  Map<String, dynamic> get _currentWord =>
      wordsByLevel[_selectedLevel]?[_wordIndex % wordsByLevel[_selectedLevel]!.length] ?? {};

  Future<void> _loadWords() async {
    setState(() {
      _loading = true;
    });
    wordsByLevel = await loadWords(_selectedLanguage);
    setState(() {
      _selectedLevel = wordsByLevel.keys.first;
      _wordIndex = 0;
      _loading = false;
    });
  }

  void _scheduleNotification() async {
    final word = _currentWord;
    String title, body;
    if (_selectedLanguage == Language.turkish) {
      title = 'Turkish Word of the Day';
      body = '${word['turkish_word']} - ${word['english_meaning']}';
    } else {
      title = 'Chinese Word of the Day';
      body = '${word['chinese']} - ${word['explanation']}';
    }
    await widget.notifications.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfNineAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails('daily_word', 'Daily Word'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification scheduled for 9:00 AM')));
  }

  tz.TZDateTime _nextInstanceOfNineAM() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 9);
    return tz.TZDateTime.from(tomorrow, tz.local);
  }

  @override
  void initState() {
    super.initState();
    // Required for timezone support
    tz.initializeTimeZones();
    _loadWords();
  }

  void _openSettings() async {
    final selected = await Navigator.push<Language>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(selectedLanguage: _selectedLanguage),
      ),
    );
    if (selected != null && selected != _selectedLanguage) {
      setState(() {
        _selectedLanguage = selected;
      });
      _loadWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final word = _currentWord;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Select your level:', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: _selectedLevel,
              items: wordsByLevel.keys
                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (level) {
                setState(() {
                  _selectedLevel = level!;
                  _wordIndex = 0;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              _selectedLanguage == Language.turkish ? 'Word of the Day:' : 'Chinese Word of the Day:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              _selectedLanguage == Language.turkish
                  ? (word['turkish_word'] ?? '')
                  : (word['chinese'] ?? ''),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _selectedLanguage == Language.turkish
                  ? (word['english_meaning'] ?? '')
                  : (word['explanation'] ?? ''),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _wordIndex++;
                });
                _scheduleNotification();
              },
              child: const Text('Next Word & Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _wordIndex++;
                });
                _scheduleNotification();
              },
              child: const Text('Next Word & Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

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
