
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './user_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // action პარამეტრი უნდა გადავცეთ URL-ში
    final url = Uri.parse('https://tvr.digital/api/auth.php?action=login');

    try {
      // body-ში ვაგზავნით მხოლოდ username-ს და password-ს, JSON ფორმატში
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // PHP-დან მოდის 'success' (boolean), და არა 'status' (string)
        if (data['success'] == true) {
          // PHP-დან მოდის მომხმარებლის მონაცემები პირდაპირ, და არა 'user' ობიექტში
          _user = UserModel.fromJson(data);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['message'] ?? 'Unknown error';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
