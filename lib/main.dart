import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';


// Onboarding & Pages
import 'package:my_project/screens/onboarding/OnBoardingPage.dart';
import 'package:my_project/screens/onboarding/set_location.dart';
import 'package:my_project/screens/onboarding/allow_location_page.dart';
import 'package:my_project/screens/onboarding/set_current_location_page.dart';
import 'package:my_project/screens/onboarding/find_your_place_page.dart';
import 'package:my_project/screens/onboarding/success_page.dart';
import 'package:my_project/screens/splash_screen.dart';
import 'package:my_project/screens/auth/login.dart';
import 'package:my_project/screens/profile/profile_page.dart';
import 'package:my_project/screens/settings/settings.dart';
// ignore: unused_import
import 'package:my_project/screens/favorites.dart' hide FavoritesScreen;


// **Added notifications import here**
import 'package:my_project/screens/notifications.dart' hide ProfilePage, SettingsPage;

// **Added admin import**
import 'package:my_project/screens/admin/admin_panel.dart';


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
  String userEmail = prefs.getString('userEmail') ?? '';


  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(
        onboardingCompleted: onboardingCompleted,
        isLoggedIn: isLoggedIn,
        username: username,
        userEmail: userEmail,
      ),
    ),
  );
}


class MyApp extends StatelessWidget {
  final bool onboardingCompleted;
  final bool isLoggedIn;
  final String username;
  final String userEmail;


  const MyApp({
    super.key,
    required this.onboardingCompleted,
    required this.isLoggedIn,
    required this.username,
    required this.userEmail,
  });


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);


    // Decide initial route based on onboarding and login status
    String initialRoute;
    if (!onboardingCompleted) {
      initialRoute = '/splash_initial'; // splash without buttons, then onboarding
    } else {
      if (isLoggedIn) {
        // Check if admin email
        if (userEmail == 'gala.admin@gmail.com') {
          initialRoute = '/admin_panel';
        } else {
          initialRoute = '/homepage';
        }
      } else {
        initialRoute = '/splash_auth'; // splash with buttons, then login/signup
      }
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
      onGenerateRoute: (settings) {
        switch (settings.name) {
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


          case '/set_location':
            return MaterialPageRoute(builder: (_) => SetLocationPage());


          case '/allow_location':
            return MaterialPageRoute(builder: (_) => const AllowLocationPage());


          case '/set_current_location':
            return MaterialPageRoute(
                builder: (_) => const SetCurrentLocationPage());


          case '/find_your_place':
            return MaterialPageRoute(builder: (_) => FindYourPlacePage());


          case '/success':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => LocationConfirmedPage(
                location: args?['location'] ?? 'Unknown',
              ),
            );


          case '/onboarding':
            return MaterialPageRoute(
              builder: (context) => OnboardingPage(
                onboardingCompleted: (ctx) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_completed', true);
                  Navigator.pushReplacementNamed(ctx, '/splash_auth'); // Go to splash with buttons
                },
              ),
            );


          case '/homepage':
            final args = settings.arguments as Map<String, dynamic>?;
            // Use username from args if provided, else fallback to MyApp's username
            final user = args?['username'] ?? username;
            return MaterialPageRoute(
              builder: (_) => home.HomePage(username: user),
            );

          case '/admin_panel':
            return MaterialPageRoute(builder: (_) => const AdminPanelPage());


          case '/favorites':
            return MaterialPageRoute(builder: (_) => FavoritesScreen());


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
