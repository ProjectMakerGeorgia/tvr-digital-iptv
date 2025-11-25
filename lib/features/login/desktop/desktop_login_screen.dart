
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth_service.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _loginButtonFocusNode = FocusNode();

  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final password = prefs.getString('password');
    if (mounted && username != null && password != null) {
      setState(() {
        _usernameController.text = username;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('password', _passwordController.text);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        color: Colors.black.withAlpha(179),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withAlpha(51)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 20),
                const Text(
                  'TVR DIGITAL IPTV',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'FullAppFont',
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  style: const TextStyle(color: Colors.white, fontFamily: 'FullAppFont'),
                  decoration: InputDecoration(
                    labelText: 'მომხმარებელი',
                    labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'FullAppFont'),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'შეიყვანეთ მომხმარებლის სახელი' : null,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscureText,
                  style: const TextStyle(color: Colors.white, fontFamily: 'FullAppFont'),
                  decoration: InputDecoration(
                    labelText: 'პაროლი',
                    labelStyle: const TextStyle(color: Colors.white70, fontFamily: 'FullAppFont'),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'შეიყვანეთ პაროლი' : null,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_loginButtonFocusNode);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    const Text('დამახსოვრება', style: TextStyle(color: Colors.white, fontFamily: 'FullAppFont')),
                  ],
                ),
                const SizedBox(height: 20),
                authService.isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withAlpha(128),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          focusNode: _loginButtonFocusNode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final authService = Provider.of<AuthService>(context, listen: false);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              await _saveUserCredentials();

                              final success = await authService.login(
                                _usernameController.text,
                                _passwordController.text,
                              );

                              if (!mounted) return;

                              if (!success) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(authService.errorMessage ?? 'ავტორიზაცია ვერ მოხერხდა'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('შესვლა', style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'FullAppFont')),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
