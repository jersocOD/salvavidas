import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class Styles {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static get appBarTitleStyle {
    return GoogleFonts.eczar().copyWith(
        fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 25);
  }
}
