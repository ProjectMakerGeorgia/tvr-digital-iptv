
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'dart:ui';

import 'features/login/desktop/desktop_login_screen.dart';
import 'features/login/mobile/mobile_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget loginForm;
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      loginForm = const DesktopLoginScreen();
    } else {
      loginForm = const MobileLoginScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: loginForm,
          ),
        ),
      ),
    );
  }
}
