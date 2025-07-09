import 'package:flutter/material.dart';
import 'package:smartify/pages/menu/menu_page.dart';
import 'package:smartify/pages/tracker/main_tracker_page.dart';
import 'package:smartify/pages/universities/main_university_page.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/nav/nav_page.dart';
import 'package:smartify/pages/recommendations/recommendation_screen.dart';

void main() async {
  /**/
  // ВРЕМЕННАЯ ОЧИСТКА — удалит все сохранённые токены!
  //const storage = FlutterSecureStorage();
  //await storage.deleteAll();
  
  // Проверка аутентификации
  final isAuthenticated = await AuthService.isAuthenticated();
  runApp(MyApp(widget: isAuthenticated ? const DashboardPage() : const WelcomePage()));
}
class MyApp extends StatelessWidget {
  final Widget widget;  
  const MyApp({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: widget,
      //home: const DashboardPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
