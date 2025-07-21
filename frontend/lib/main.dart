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

  // Проверка аутентификации
  final isAuthenticated = await AuthService.isAuthenticated();

  runApp(
    MyApp(
      startWidget: isAuthenticated ? const DashboardPage() : const WelcomePage(),
    ),
  );
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
              title: 'Smartify',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF23272F),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF23272F),
                  foregroundColor: Colors.white,
                ),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                  background: Color(0xFF23272F),
                  surface: Color(0xFF23272F),
                  onBackground: Colors.white,
                  onSurface: Colors.white,
                  primary: Colors.white,
                  secondary: Colors.white,
                ),
                cardColor: const Color(0xFF2C313A),
                dialogBackgroundColor: const Color(0xFF23272F),
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
              builder: (context, child) {
                return CenteredWrapper(child: child!);
              },
              home: startWidget,
            );
          },
        );
      },
    );
  }
}

/// Центрирование приложения на широких экранах
class CenteredWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600, // ширина основной части приложения
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF23272F)
          : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              width: constraints.maxWidth > maxWidth
                  ? maxWidth
                  : constraints.maxWidth,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

// Пример простой страницы
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
