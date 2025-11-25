import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for KeyEvent
import 'package:provider/provider.dart';
import '../../../auth_service.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginButtonFocusNode = FocusNode();
  bool _obscurePassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (error != null) {
        _errorMessage = error;
      }
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) { // Updated to KeyEvent
    if (event is KeyDownEvent) { // Updated to KeyDownEvent
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_usernameFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _loginButtonFocusNode.requestFocus();
        } else if (_loginButtonFocusNode.hasFocus) {
          _usernameFocusNode.requestFocus(); // Loop back to the top
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_loginButtonFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _usernameFocusNode.requestFocus();
        } else if (_usernameFocusNode.hasFocus) {
          _loginButtonFocusNode.requestFocus(); // Loop back to the bottom
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left side - Welcome Message
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'TVR Digital',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'FullAppFont',
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'მოგესალმებით! გთხოვთ, გაიაროთ ავტორიზაცია.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontFamily: 'FullAppFont',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right side - Login Form
                  Expanded(
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none, // Allow logo to overflow
                        alignment: Alignment.topCenter,
                        children: [
                          // The Card
                          Padding(
                            padding: const EdgeInsets.only(top: 50), // Space for top half of logo
                            child: FocusScope(
                              child: Focus(
                                onKeyEvent: _handleKeyEvent, // Updated to onKeyEvent
                                child: Container(
                                  width: 400,
                                  padding: const EdgeInsets.fromLTRB(32, 80, 32, 32), // More top padding inside
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(200),
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(25),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: _buildLoginForm(),
                                ),
                              ),
                            ),
                          ),
                          // The Logo on top
                          Positioned(
                            top: 0,
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'ავტორიზაცია',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'AppBarFont',
          ),
        ),
        const SizedBox(height: 24),
        // Username Field
        TextFormField(
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          autofocus: true, // Start focus here
          decoration: InputDecoration(
            labelText: 'მომხმარებლის სახელი',
            prefixIcon: const Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 16),
        // Password Field
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'პაროლი',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: _togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onFieldSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 24),
        // Loading indicator and Error message
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 16),
        // Login Button
        ElevatedButton(
          focusNode: _loginButtonFocusNode,
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'შესვლა',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
