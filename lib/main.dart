// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Onboarding & Pages
import 'package:my_project/screens/onboarding/OnBoardingPage.dart';
// ... (other imports)
import 'package:my_project/screens/splash_screen.dart';
import 'package:my_project/screens/auth/login.dart';
import 'package:my_project/screens/profile/profile_page.dart';
import 'package:my_project/screens/settings/settings.dart';

// Import the MapScreen from demomap.dart (or wherever you saved it)
import 'package:my_project/screens/demomap.dart'; // Assuming MapScreen is here

import 'package:my_project/theme/theme.dart';
import 'package:my_project/theme/theme_notifier.dart';

// Conflict-resolved imports
import 'package:my_project/screens/auth/signup_page.dart' as auth;
import 'package:my_project/screens/home/homepage.dart' as home;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String username = prefs.getString('username') ?? 'Guest';

  // 🎯 FIX: Corrected runApp to use MyApp 🎯
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(
        onboardingCompleted: onboardingCompleted,
        isLoggedIn: isLoggedIn,
        username: username,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  final bool isLoggedIn;
  final String username;

  const MyApp({
    Key? key,
    required this.onboardingCompleted,
    required this.isLoggedIn,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    // Decide initial route based on onboarding and login status
    String initialRoute;
    if (!onboardingCompleted) {
      initialRoute = '/splash_initial';
    } else {
      initialRoute = isLoggedIn ? '/homepage' : '/splash_auth';
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gala App',
      theme: lightTheme.copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Inter'),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Inter'),
      ),
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: initialRoute,
      routes: {
        // 🎯 FIX: Added the MapScreen to the routes table 🎯
        '/demomap': (context) => const MapScreen(),
        // You can now navigate to the map screen using Navigator.pushNamed(context, '/demomap');
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
        // ... (existing routes)
          case '/splash_initial':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(showButtons: false),
            );

          case '/splash_auth':
            return MaterialPageRoute(
              builder: (_) => const SplashScreen(showButtons: true),
            );

          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/signup':
            return MaterialPageRoute(builder: (_) => auth.SignUpPage());

          case '/homepage':
            final args = settings.arguments as Map<String, dynamic>?;
            final user = args?['username'] ?? username;
            return MaterialPageRoute(
              builder: (_) => home.HomePage(username: user),
            );
        // ... (other routes)
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());

          case '/profile':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ProfilePage(
                onSettingsTap: args['onSettingsTap'],
                username: '',
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('404 - Page not found')),
              ),
            );
        }
      },
    );
  }
}