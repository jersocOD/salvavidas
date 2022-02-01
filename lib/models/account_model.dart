import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AccountModel with ChangeNotifier {
  User? _user;

  User? get user => _user;

  set user(newValue) {
    _user = newValue;
    notifyListeners();
  }
}
