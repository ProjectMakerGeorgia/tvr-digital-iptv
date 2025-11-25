import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'features/login/desktop/desktop_login_screen.dart';
import 'features/login/mobile/mobile_login_screen.dart';
import 'features/responsive/responsive_layout.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.tryAutoLogin();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: authService,
      child: MaterialApp(
        title: 'TVR Digital',
        theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'FullAppFont',
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
          return const ResponsiveLayout(
            desktopBody: DesktopLoginScreen(),
            mobileBody: MobileLoginScreen(),
          );
        }
      },
    );
  }
}
