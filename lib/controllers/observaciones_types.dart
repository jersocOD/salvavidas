import 'package:flutter_translate/flutter_translate.dart';

class Observaciones {
  //"Niño abandonado por padres fallecidos por Covid",
  static List<String> observaciones = [
    "Huérfano por Covid",
    "Abandonado",
    "Perdido",
    "En peligro/vulnerable",
    "Huérfano",
  ];

  List<String> observacionesIntl = [
    "Huérfano por Covid",
    "Abandonado/Sin Hogar",
    "Perdido",
    "En peligro/Vulnerable",
    "Huérfano",
  ];

  List<String> getMapIntl() {
    return observacionesIntl = [
      translate('ChildCase.Types.OrphanedByCovid'),
      translate('ChildCase.Types.Abandoned'),
      translate('ChildCase.Types.Lost'),
      translate('ChildCase.Types.Endangered/Vulnerable'),
      translate('ChildCase.Types.Orphan'),
    ];
  }
}
