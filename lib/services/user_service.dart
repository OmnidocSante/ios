import 'package:flutter/material.dart';
import '../api/user_api.dart';

class UserService extends ChangeNotifier {
  Map<String, dynamic> _userInfo = {};

  Map<String, dynamic> get userInfo => _userInfo;

  Future<void> loadUserInfo() async {
    try {
      _userInfo = await UserApi.getUserInfo();
      notifyListeners();
    } catch (e) {
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> newInfo) async {
    try {
      _userInfo = newInfo;
      notifyListeners();
    } catch (e) {
    }
  }
}
