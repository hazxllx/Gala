import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:my_project/screens/onboarding/OnBoardingPage.dart';
import 'package:my_project/screens/onboarding/set_location.dart';
import 'package:my_project/screens/onboarding/allow_location_page.dart';
import 'package:my_project/screens/onboarding/set_current_location_page.dart';
import 'package:my_project/screens/onboarding/find_your_place_page.dart';
import 'package:my_project/screens/onboarding/success_page.dart';
import 'package:my_project/screens/splash_screen.dart';
import 'package:my_project/screens/auth/login.dart';
import 'package:my_project/screens/auth/signup_page.dart';
import 'package:my_project/screens/home/homepage.dart';
import 'package:my_project/screens/profile/profile_page.dart';
import 'package:my_project/screens/settings/settings.dart';
import 'package:my_project/theme/theme.dart';
import 'package:my_project/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  bool onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(onboardingCompleted: onboardingCompleted),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({Key? key, required this.onboardingCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

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
      initialRoute: onboardingCompleted ? '/' : '/onboarding',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => SignUpPage());
          case '/set_location':
            return MaterialPageRoute(builder: (_) => const SetLocationPage());

          case '/allow_location':
            return MaterialPageRoute(builder: (_) => const AllowLocationPage());

          case '/set_current_location':
            return MaterialPageRoute(
              builder: (_) => const SetCurrentLocationPage(),
            );
          case '/find_your_place':
            return MaterialPageRoute(builder: (_) => FindYourPlacePage());
          case '/success':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder:
                  (_) => LocationConfirmedPage(
                    location: args?['location'] ?? 'Unknown',
                  ),
            );

          case '/onboarding':
            return MaterialPageRoute(
              builder:
                  (context) => OnboardingPage(
                    onboardingCompleted: (ctx) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', true);
                      Navigator.pushReplacementNamed(ctx, '/set_location');
                    },
                  ),
            );

          case '/homepage':
            final args = settings.arguments as Map<String, dynamic>?;

            final username =
                args != null && args.containsKey('username')
                    ? args['username']
                    : 'Guest';

            return MaterialPageRoute(
              builder: (_) => HomePage(username: username),
            );

          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsPage());
          case '/profile':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => ProfilePage(onSettingsTap: args['onSettingsTap']),
            );
          default:
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('404 - Page not found')),
                  ),
            );
        }
      },
    );
  }
}
