import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'profile_screen.dart';
import 'qr_scanner_screen.dart'; // Import the new scanner screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('მთავარი', style: TextStyle(fontFamily: 'AppBarFont', color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white), // QR Scanner Icon
            tooltip: 'Scan QR Code',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            tooltip: 'პროფილი',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'გასვლა',
            onPressed: () {
              authService.logout();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            color: const Color.fromRGBO(255, 255, 255, 0.5),
            height: 1.0,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const Center(
            child: Text(
              'მოგესალმებით!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'FullAppFont',
                shadows: [
                  Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(5.0, 5.0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
