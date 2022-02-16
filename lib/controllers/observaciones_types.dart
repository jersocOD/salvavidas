import 'dart:io';

import 'package:flutter_translate/flutter_translate.dart';

class Observaciones {
  //"Niño abandonado por padres fallecidos por Covid",
  static List<String> observaciones = [
    if (Platform.isAndroid) "Huérfano por Covid",
    "Huérfano",
    "Abandonado",
    "Perdido",
    "En peligro/vulnerable",
  ];

  List<String> observacionesIntl = [
    if (Platform.isAndroid) "Huérfano por Covid",
    "Huérfano",
    "Abandonado/Sin Hogar",
    "Perdido",
    "En peligro/Vulnerable",
  ];

  List<String> getMapIntl() {
    return observacionesIntl = [
      if (Platform.isAndroid) translate('ChildCase.Types.OrphanedByCovid'),
      translate('ChildCase.Types.Orphan'),
      translate('ChildCase.Types.Abandoned'),
      translate('ChildCase.Types.Lost'),
      translate('ChildCase.Types.Endangered/Vulnerable'),
    ];
  }
}
