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

// Main Screen Widget
class DesktopLoginScreen extends StatelessWidget {
  const DesktopLoginScreen({super.key});

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
          child: const Center(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: WelcomeMessage()),
                  Expanded(child: Center(child: LoginViewContainer())),
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

class LoginViewContainer extends StatelessWidget {
  const LoginViewContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            child: const LoginBox(),
          ),
        ),
        Positioned(
          top: 0,
          child: Image.asset('assets/images/logo.png', height: 100),
        ),
      ],
    );
  }
}

class LoginBox extends StatefulWidget {
  const LoginBox({super.key});

  @override
  State<LoginBox> createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> with TickerProviderStateMixin {
  late TabController _tabController;
  final FocusNode _manualTabFocusNode = FocusNode();
  final FocusNode _qrTabFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _loginButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _manualTabFocusNode.addListener(() {
      if (_manualTabFocusNode.hasFocus) {
        _tabController.index = 0;
      }
    });
    _qrTabFocusNode.addListener(() {
      if (_qrTabFocusNode.hasFocus) {
        _tabController.index = 1;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_manualTabFocusNode);
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    setState(() {}); // Re-render on tab change
    if (_tabController.index == 0) {
      _manualTabFocusNode.requestFocus();
    } else {
      _qrTabFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _manualTabFocusNode.dispose();
    _qrTabFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _loginButtonFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight && _manualTabFocusNode.hasFocus) {
      _tabController.index = 1;
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _qrTabFocusNode.hasFocus) {
      _tabController.index = 0;
      return KeyEventResult.handled;
    }

    if (_tabController.index == 0) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (_manualTabFocusNode.hasFocus) {
          _usernameFocusNode.requestFocus();
        } else if (_usernameFocusNode.hasFocus) {
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
          _manualTabFocusNode.requestFocus();
        }
        return KeyEventResult.handled;
      }
    } else { // QR Tab
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _qrTabFocusNode.requestFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) => _handleKeyEvent(event),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.deepPurple,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.input, color: _manualTabFocusNode.hasFocus ? Colors.deepPurple : Colors.black54), const SizedBox(width: 8), const Text('ხელით')])), 
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.qr_code, color: _qrTabFocusNode.hasFocus ? Colors.deepPurple : Colors.black54), const SizedBox(width: 8), const Text('QR კოდით')]))
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 450),
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: [
                ManualLoginView(
                    usernameFocusNode: _usernameFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    loginButtonFocusNode: _loginButtonFocusNode),
                const QrLoginView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ManualLoginView extends StatefulWidget {
  final FocusNode usernameFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode loginButtonFocusNode;

  const ManualLoginView({
    super.key,
    required this.usernameFocusNode,
    required this.passwordFocusNode,
    required this.loginButtonFocusNode,
  });

  @override
  State<ManualLoginView> createState() => _ManualLoginViewState();
}

class _ManualLoginViewState extends State<ManualLoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Future<void> _login() async {
    if (_isLoading) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      setState(() => _errorMessage = 'გთხოვთ, შეავსოთ მონაცემები');
      return;
    } else if (username.isEmpty) {
      setState(() => _errorMessage = 'ჩაწერეთ მომხმარებლის სახელი');
      return;
    } else if (password.isEmpty) {
      setState(() => _errorMessage = 'ჩაწერეთ პაროლი');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.login(username, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('ავტორიზაცია', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'AppBarFont')),
          const SizedBox(height: 24),
          TextFormField(
            controller: _usernameController,
            focusNode: widget.usernameFocusNode,
            decoration: InputDecoration(
              labelText: 'მომხმარებლის სახელი',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onFieldSubmitted: (_) => widget.passwordFocusNode.requestFocus(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            focusNode: widget.passwordFocusNode,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'პაროლი',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: _togglePasswordVisibility),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            onFieldSubmitted: (_) => _login(),
          ),
          const SizedBox(height: 32),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              focusNode: widget.loginButtonFocusNode,
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('შესვლა', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

// ... (QrLoginView remains the same)
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
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final url = Uri.parse('https://tvr.dogital/api/tv/check-auth.php?token=$_token');
        final response = await http.get(url);

        if (!mounted) {
          return;
        }

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            timer.cancel();
            final userData = data['user_data'];
            Provider.of<AuthService>(context, listen: false).completeQrLogin(userData);
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
          const Text('ავტორიზაცია QR კოდით', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'AppBarFont'), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Text('1. გახსენით აპლიკაცია მობილურზე.\n2. გადადით პროფილში და დააჭირეთ QR ხატულას.\n3. დაასკანერეთ მოცემული კოდი.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 20),
          Center(child: QrImageView(data: qrData, version: QrVersions.auto, size: 200.0, backgroundColor: Colors.white)),
          const SizedBox(height: 30),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 40.0), child: LinearProgressIndicator()),
        ],
      ),
    );
  }
}
