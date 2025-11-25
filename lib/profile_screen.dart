import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'user_model.dart';
import 'subscription_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Consumer<AuthService>(
                builder: (context, authService, child) {
                  final UserModel? user = authService.user;

                  if (user == null) {
                    return const Center(
                        child: Text('მონაცემები იტვირთება...', style: TextStyle(color: Colors.white)));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.black.withAlpha(160), // Updated from withOpacity
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(user),
                            const SizedBox(height: 20),
                            if (user.subscription != null) ...[
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 20),
                              _buildSubscriptionCard(user.subscription!),
                              const SizedBox(height: 20),
                            ] else ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            ],
                            const Divider(color: Colors.white30),
                            const SizedBox(height: 20),
                             _buildProfileDetail(Icons.person, 'მომხმარებლის სახელი:', user.username),
                            _buildProfileDetail(Icons.email, 'ელ.ფოსტა:', user.email ?? '-'),
                            _buildProfileDetail(Icons.phone, 'ტელეფონი:', user.phone ?? '-'),
                            _buildProfileDetail(Icons.account_balance_wallet, 'ბალანსი:', '${user.balance.toStringAsFixed(2)} GEL'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withAlpha(50), // Updated from withOpacity
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'გამოწერა',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'FullAppFont'),
          ),
          const SizedBox(height: 12),
          _buildProfileDetail(Icons.star_border, 'პაკეტი:', subscription.packageName),
          _buildProfileDetail(Icons.date_range, 'სრულდება:', subscription.endDate.toLocal().toString().substring(0, 10)),
          _buildProfileDetail(Icons.check_circle_outline, 'სტატუსი:', subscription.status,
              valueColor: subscription.status == 'ACTIVE' ? Colors.greenAccent : Colors.redAccent),
        ],
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

  Widget _buildProfileDetail(IconData icon, String label, String value, {bool isSelectable = false, Color? valueColor}) {
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
                        style: TextStyle(
                            fontSize: 15,
                            color: valueColor ?? Colors.white,
                            fontFamily: 'FullAppFont',
                            fontWeight: FontWeight.w500),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
