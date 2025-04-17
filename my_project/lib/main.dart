import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'darkmode.dart';        // Import your theme provider
import 'homepage.dart';       // Import your home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Allows async before runApp()

  // Initialize the ThemeProvider and wait for SharedPreferences to load
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gala',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode, // Use the current theme mode
      home: const HomePage(),             // Your initial screen
    );
  }
}
