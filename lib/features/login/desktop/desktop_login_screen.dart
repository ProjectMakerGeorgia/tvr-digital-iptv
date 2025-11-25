import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../../../auth_service.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  const Expanded(
                    child: WelcomeMessage(),
                  ),
                  Expanded(
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Container(
                                width: 400,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(200),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: LoginBox(tabController: _tabController)),
                          ),
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
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(5.0, 5.0))],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'მოგესალმებით! გთხოვთ, გაიაროთ ავტორიზაცია.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
              fontFamily: 'FullAppFont',
              shadows: [Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(3.0, 3.0))],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginBox extends StatelessWidget {
  final TabController tabController;
  const LoginBox({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: TabBar(
            controller: tabController,
            indicatorColor: Colors.deepPurple,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(icon: Icon(Icons.input), text: 'ხელით'),
              Tab(icon: Icon(Icons.qr_code), text: 'QR კოდით'),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 450), // Increased height slightly
          child: TabBarView(
            controller: tabController,
            children: const [
              ManualLoginView(),
              QrLoginView(),
            ],
          ),
        ),
      ],
    );
  }
}

class ManualLoginView extends StatefulWidget {
  const ManualLoginView({super.key});

  @override
  State<ManualLoginView> createState() => _ManualLoginViewState();
}

class _ManualLoginViewState extends State<ManualLoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _loginButtonFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_usernameFocusNode);
    });
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

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
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

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_usernameFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _loginButtonFocusNode.requestFocus();
        } else if (_loginButtonFocusNode.hasFocus) {
          _usernameFocusNode.requestFocus();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_loginButtonFocusNode.hasFocus) {
          _passwordFocusNode.requestFocus();
        } else if (_passwordFocusNode.hasFocus) {
          _usernameFocusNode.requestFocus();
        } else if (_usernameFocusNode.hasFocus) {
          _loginButtonFocusNode.requestFocus();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
          children: [
            const Text(
              'ავტორიზაცია',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'AppBarFont'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameController,
              focusNode: _usernameFocusNode,
              decoration: InputDecoration(
                labelText: 'მომხმარებლის სახელი',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),
            const SizedBox(height: 16),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onFieldSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              focusNode: _loginButtonFocusNode,
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('შესვლა', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class QrLoginView extends StatefulWidget {
  const QrLoginView({super.key});

  @override
  State<QrLoginView> createState() => _QrLoginViewState();
}

class _QrLoginViewState extends State<QrLoginView> {
  String? _token;
  Timer? _authCheckTimer;

  @override
  void initState() {
    super.initState();
    _generateTokenAndStartPolling();
  }

  void _generateTokenAndStartPolling() {
    setState(() {
      _token = const Uuid().v4();
    });
    _startPolling();
  }

  void _startPolling() {
    _authCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_token == null || !mounted) {
        timer.cancel();
        return;
      }
      try {
        final url = Uri.parse('https://tvr.dogital/api/tv/check-auth.php?token=$_token');
        final response = await http.get(url);

        if (!mounted) return; 
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            timer.cancel();
            final userData = data['user_data'];
            final authService = Provider.of<AuthService>(context, listen: false);
            await authService.completeQrLogin(userData);
          }
        }
      } catch (e) {
        // Silently ignore
      }
    });
  }

  @override
  void dispose() {
    _authCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final qrData = 'https://tvr.dogital/api/tv/tv-auth.php?token=$_token';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ავტორიზაცია QR კოდით',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'AppBarFont'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            '1. გახსენით აპლიკაცია მობილურზე.\n2. გადადით პროფილში და დააჭირეთ QR ხატულას.\n3. დაასკანერეთ მოცემული კოდი.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
