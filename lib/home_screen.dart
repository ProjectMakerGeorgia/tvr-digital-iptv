
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _logoutButtonFocusNode = FocusNode();

  @override
  void dispose() {
    _logoutButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('მთავარი', style: TextStyle(fontFamily: 'AppBarFont')),
        actions: [
          IconButton(
            focusNode: _logoutButtonFocusNode,
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
            },
          )
        ],
      ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'მოგესალმებით, ${user?.username ?? 'მომხმარებელი'}!',
                  style: const TextStyle(fontSize: 24, fontFamily: 'FullAppFont'),
                ),
                const SizedBox(height: 16),
                Text(
                  'ელ.ფოსტა: ${user?.email ?? ''}',
                  style: const TextStyle(fontSize: 16, fontFamily: 'FullAppFont'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
