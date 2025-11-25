import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'subscription_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  static const String _userPrefKey = 'userData';
  final String _baseUrl = 'tvr.digital';

  // Unified method to set user data, save to prefs, and notify listeners
  Future<void> _setUserAndCache(UserModel? user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      final userData = jsonEncode(user.toJson());
      await prefs.setString(_userPrefKey, userData);
    } else {
      await prefs.remove(_userPrefKey);
    }
    notifyListeners();
  }

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
          final basicUser = UserModel.fromJson(data);
          // Fetch full details and then set user
          await _fetchAndMergeUserDetails(basicUser.id.toString(), basicUser);
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

  Future<void> _fetchAndMergeUserDetails(String userId, [UserModel? baseUser]) async {
    final url = Uri.https(_baseUrl, '/api/user_info.php', {'user_id': userId});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
            final detailedData = data['data'];
            // Use the base user if provided, otherwise create a new one
            final userToUpdate = baseUser ?? _user;
            
            if (userToUpdate != null) {
                 final updatedUser = userToUpdate.copyWith(
                    firstName: detailedData['firstName'],
                    lastName: detailedData['lastName'],
                    email: detailedData['email'],
                    phone: detailedData['phone'],
                    balance: (detailedData['balance'] as num).toDouble(),
                    subscription: detailedData['subscription'] != null
                        ? SubscriptionModel.fromJson(detailedData['subscription'])
                        : null,
                );
                await _setUserAndCache(updatedUser);
            } else {
                // This case might happen if auto-login only has userId
                final newUser = UserModel.fromJson(detailedData);
                await _setUserAndCache(newUser);
            }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Could not fetch user details: $e");
      }
    }
  }

  Future<void> logout() async {
    await _setUserAndCache(null);
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userPrefKey);
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      _user = UserModel.fromJson(userData);
      notifyListeners(); 
    }
  }

  Future<void> completeQrLogin(Map<String, dynamic> userData) async {
    final basicUser = UserModel.fromJson({'success': true, ...userData});
    // After getting basic data from QR, fetch full details
    await _fetchAndMergeUserDetails(basicUser.id.toString(), basicUser);
  }
  
  Future<Map<String, dynamic>> authorizeQrToken(String qrToken) async {
     if (_user?.token == null) {
      return {'success': false, 'message': 'Mobile user not logged in.'};
    }

    final url = Uri.https(_baseUrl, '/api/tv/check-auth.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'qr_token': qrToken,
          'user_token': _user!.token,
        })
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
