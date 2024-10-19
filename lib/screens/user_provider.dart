// user_provider.dart
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _password = '';

  String get username => _username;
  String get password => _password;

  void setUserInfo(String username, String password) {
    _username = username;
    _password = password;
    notifyListeners();
  }
}
