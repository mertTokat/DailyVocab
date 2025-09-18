import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

// Demo data: Replace with parsed JSON for real use
const Map<String, List<Map<String, String>>> turkishWordsByLevel = {
  'Beginner': [
    {'word': 'merhaba', 'meaning': 'hello'},
    {'word': 'ev', 'meaning': 'house'},
  ],
  'Intermediate': [
    {'word': 'gelişmek', 'meaning': 'to improve'},
    {'word': 'başarı', 'meaning': 'success'},
  ],
  'Advanced': [
    {'word': 'mütevazı', 'meaning': 'modest'},
    {'word': 'istikrar', 'meaning': 'stability'},
  ],
};

class _MyHomePageState extends State<MyHomePage> {
  String _selectedLevel = 'Beginner';
  int _wordIndex = 0;

  Map<String, String> get _currentWord =>
      turkishWordsByLevel[_selectedLevel]![_wordIndex % turkishWordsByLevel[_selectedLevel]!.length];

  void _scheduleNotification() async {
    final word = _currentWord;
    await widget.notifications.zonedSchedule(
      0,
      'Turkish Word of the Day',
      '${word['word']} - ${word['meaning']}',
      // Schedule for next day at 9:00 AM
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
  }

  @override
  Widget build(BuildContext context) {
    final word = _currentWord;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Select your level:'),
            DropdownButton<String>(
              value: _selectedLevel,
              items: turkishWordsByLevel.keys
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
            Text('Word of the Day:', style: Theme.of(context).textTheme.titleMedium),
            Text(word['word']!, style: Theme.of(context).textTheme.headlineMedium),
            Text(word['meaning']!, style: Theme.of(context).textTheme.bodyLarge),
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
