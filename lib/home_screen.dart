import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'user_model.dart';
import 'profile_screen.dart'; // Import the new profile screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _logoutButtonFocusNode = FocusNode();

  @override
  void dispose() {
    _logoutButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final UserModel? user = authService.user;

    // Helper to build the welcome message
    String getWelcomeMessage() {
      if (user?.firstName != null && user?.lastName != null) {
        return '${user!.firstName} ${user.lastName}';
      }
      return user?.username ?? 'მომხმარებელი';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('მთავარი', style: TextStyle(fontFamily: 'AppBarFont')),
        actions: [
          // Profile Button
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'პროფილი',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          // Logout Button
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
            child: Card(
              color: Colors.black.withOpacity(0.5),
              elevation: 8.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'მოგესალმებით, ${getWelcomeMessage()}!',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'FullAppFont'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white54),
                    const SizedBox(height: 24),
                    _buildInfoRow(Icons.person_outline, 'მომხმარებლის სახელი', user?.username ?? '-'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.email_outlined, 'ელ.ფოსტა', user?.email ?? '-'),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.account_balance_wallet_outlined, 'ბალანსი', '${user?.balance.toStringAsFixed(2) ?? '0.00'} GEL'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 16, color: Colors.white70, fontFamily: 'FullAppFont'),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'FullAppFont'),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
