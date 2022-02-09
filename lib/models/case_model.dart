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

  Uint8List? _videoThumbnailBytes;

  Uint8List? get videoThumbnailBytes => _videoThumbnailBytes;

  set videoThumbnailBytes(newValue) {
    _videoThumbnailBytes = newValue;
    notifyListeners();
  }

  Position? _position = Position(
      longitude: 0.0,
      latitude: 0.0,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0);
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

  String _observacion = "Huérfano por Covid";

  String get observacion => _observacion;

  set observacion(newValue) {
    _observacion = newValue;
    notifyListeners();
  }

  String _placemark = "";
  String get placemark => _placemark;

  set placemark(newValue) {
    _placemark = newValue;
    notifyListeners();
  }
}
