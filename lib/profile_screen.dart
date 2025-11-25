import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final UserModel? user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('პროფილი', style: TextStyle(fontFamily: 'AppBarFont')),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.black.withOpacity(0.6),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: user == null
                        ? const Text('მომხმარებლის მონაცემები მიუწვდომელია', style: TextStyle(color: Colors.white)) 
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(user),
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 20),
                              _buildProfileDetail(Icons.person, 'მომხმარებლის სახელი:', user.username),
                              _buildProfileDetail(Icons.email, 'ელ.ფოსტა:', user.email ?? '-'),
                              _buildProfileDetail(Icons.phone, 'ტელეფონი:', user.phone ?? '-'),
                              _buildProfileDetail(Icons.link, 'Playlist URL:', user.playlistUrl ?? '-', isSelectable: true),
                              _buildProfileDetail(Icons.account_balance_wallet, 'ბალანსი:', '${user.balance.toStringAsFixed(2)} GEL'),
                              _buildProfileDetail(Icons.info, 'სტატუსი:', user.userstatus == 1 ? 'აქტიური' : 'არააქტიური'),
                              _buildProfileDetail(Icons.date_range, 'რეგისტრაცია:', user.createdAt.toLocal().toString().substring(0, 16)),
                              _buildProfileDetail(Icons.update, 'განახლება:', user.updatedAt.toLocal().toString().substring(0, 16)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple.shade300,
          child: Text(
            user.firstName?.isNotEmpty == true ? user.firstName![0].toUpperCase() : user.username[0].toUpperCase(),
            style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty 
                ? user.username 
                : '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'FullAppFont'),
            ),
            const SizedBox(height: 4),
            Text(
              user.email ?? 'ელ.ფოსტა არ არის მითითებული',
              style: const TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'FullAppFont'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetail(IconData icon, String label, String value, {bool isSelectable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'FullAppFont'),
                ),
                const SizedBox(height: 4),
                isSelectable 
                  ? SelectableText(
                      value,
                      style: const TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'FullAppFont', fontWeight: FontWeight.w500),
                    )
                  : Text(
                      value,
                      style: const TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'FullAppFont', fontWeight: FontWeight.w500),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

