import 'package:flutter/material.dart';

void showInSnackBar(String message, GlobalKey<ScaffoldState> key) {
  // ignore: deprecated_member_use
  key.currentState?.showSnackBar(SnackBar(content: Text(message)));
}
