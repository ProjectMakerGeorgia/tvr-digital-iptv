import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'features/login/desktop/desktop_login_screen.dart';
import 'features/login/mobile/mobile_login_screen.dart';
import 'features/responsive/responsive_layout.dart'; // Corrected import path
import 'home_screen.dart';

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready
  final authService = AuthService();
  await authService.tryAutoLogin(); // Wait for auto-login to complete

  runApp(MyApp(authService: authService)); // Pass the service to the app
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value( // Use .value constructor
      value: authService,
      child: MaterialApp(
        title: 'TVR Digital',
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'FullAppFont', // Default font for the entire app
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(fontFamily: 'AppBarFont', fontSize: 20),
            )),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoggedIn) {
          return const HomeScreen();
        } else {
          // The ResponsiveLayout will handle the platform detection
          return const ResponsiveLayout(
            desktopBody: DesktopLoginScreen(),
            mobileBody: MobileLoginScreen(),
          );
        }
      },
    );
  }
}
