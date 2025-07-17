import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartify/l10n/app_localizations.dart';
import 'package:smartify/pages/menu/menu_page.dart';
import 'package:smartify/pages/tracker/main_tracker_page.dart';
import 'package:smartify/pages/universities/main_university_page.dart';
import 'package:smartify/pages/welcome/welcome_page.dart';
import 'package:smartify/pages/nav/nav_page.dart';
import 'package:smartify/pages/api_server/api_token.dart';
import 'package:smartify/pages/recommendations/recommendation_screen.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final localeNotifier = ValueNotifier<Locale?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  // ВРЕМЕННАЯ ОЧИСТКА — удалит все сохранённые токены!
  /*
  const storage = FlutterSecureStorage();
  await storage.deleteAll();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  */
  // Проверка аутентификации
  final isAuthenticated = await AuthService.isAuthenticated();
  runApp(MyApp(startWidget: isAuthenticated ? const DashboardPage() : const WelcomePage()));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;
  const MyApp({super.key, required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                  background: Colors.black,
                  surface: Colors.black,
                  onBackground: Colors.white,
                  onSurface: Colors.white,
                  primary: Colors.white,
                  secondary: Colors.white,
                ),
                cardColor: Colors.grey[900],
                dialogBackgroundColor: Colors.black,
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white),
                  bodySmall: TextStyle(color: Colors.white),
                  displayLarge: TextStyle(color: Colors.white),
                  displayMedium: TextStyle(color: Colors.white),
                  displaySmall: TextStyle(color: Colors.white),
                  headlineLarge: TextStyle(color: Colors.white),
                  headlineMedium: TextStyle(color: Colors.white),
                  headlineSmall: TextStyle(color: Colors.white),
                  titleLarge: TextStyle(color: Colors.white),
                  titleMedium: TextStyle(color: Colors.white),
                  titleSmall: TextStyle(color: Colors.white),
                  labelLarge: TextStyle(color: Colors.white),
                  labelMedium: TextStyle(color: Colors.white),
                  labelSmall: TextStyle(color: Colors.white),
                ),
              ),
              themeMode: mode,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ru'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: startWidget,
            );
          },
        );
      },
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
