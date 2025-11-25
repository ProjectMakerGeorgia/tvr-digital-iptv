import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'subscription_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  final String _baseUrl = 'tvr.digital';

  Future<String?> login(String username, String password) async {
    final url = Uri.https(_baseUrl, '/api/auth.php', {'action': 'login'});
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _user = UserModel.fromJson(data);
          notifyListeners(); // Notify with basic info

          await _fetchAndMergeUserDetails(_user!.id.toString());

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', _user!.id.toString());
          await prefs.setString('token', _user!.token ?? '');

          return null;
        } else {
          return data['message'] ?? 'Login failed.';
        }
      } else {
        return 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<void> _fetchAndMergeUserDetails(String userId) async {
    final url = Uri.https(_baseUrl, '/api/user_info.php', {'user_id': userId});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          if (_user != null) {
            _user = _user!.copyWith(
              firstName: data['data']['firstName'],
              lastName: data['data']['lastName'],
              email: data['data']['email'],
              phone: data['data']['phone'],
              balance: (data['data']['balance'] as num).toDouble(),
              subscription: data['data']['subscription'] != null
                  ? SubscriptionModel.fromJson(data['data']['subscription'])
                  : null,
            );
          } else {
            _user = UserModel.fromJson(data['data']);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Could not fetch user details: $e");
      }
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      await _fetchAndMergeUserDetails(userId);
      // Also load the token if needed elsewhere
      final token = prefs.getString('token');
      if (_user != null && token != null) {
        _user = _user!.copyWith(token: token);
      }
    }
  }

  Future<void> completeQrLogin(Map<String, dynamic> userData) async {
    _user = UserModel.fromJson({'success': true, ...userData});
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _user!.id.toString());
    await prefs.setString('token', _user!.token ?? '');

    await _fetchAndMergeUserDetails(_user!.id.toString()); // Fetch full details

    notifyListeners();
  }
  
  Future<Map<String, dynamic>> authorizeQrToken(String qrToken) async {
    final prefs = await SharedPreferences.getInstance();
    final userToken = prefs.getString('token');

    if (userToken == null) {
      return {'success': false, 'message': 'Mobile user not logged in.'};
    }

    final url = Uri.https(_baseUrl, '/api/tv/check-auth.php', {'token': qrToken});
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

}
