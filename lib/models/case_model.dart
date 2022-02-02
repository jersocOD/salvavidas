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

  String _referencia = "";

  String get referencia => _referencia;

  set referencia(newValue) {
    _referencia = newValue;
    notifyListeners();
  }

  String _comentarios = "";

  String get comentarios => _comentarios;

  set comentarios(newValue) {
    _comentarios = newValue;
    notifyListeners();
  }

  String _observacion = "";

  String get observacion => _observacion;

  set observacion(newValue) {
    _observacion = newValue;
    notifyListeners();
  }
}
