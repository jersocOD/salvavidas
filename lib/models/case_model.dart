import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class CaseModel with ChangeNotifier {
  String? _videoPath;

  String? get videoPath => _videoPath;

  set videoPath(newValue) {
    _videoPath = newValue;
    notifyListeners();
  }

  Uint8List? _videoBytes;

  Uint8List? get videoBytes => _videoBytes;

  set videoBytes(newValue) {
    _videoBytes = newValue;
    notifyListeners();
  }

  Position? _position;
  Position? get position => _position;

  set position(newValue) {
    _position = newValue;
    notifyListeners();
  }
}
