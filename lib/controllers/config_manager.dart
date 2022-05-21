import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

ConfigManager configManager = ConfigManager();
const String _showedNotification = "showed_notification";

class ConfigManager {
  bool beta = true;
  bool mailAlwaysInSpanish = true;
  String betaMessage = "";
  bool demoMode = false;
  bool signInRequired = true;
  Future<void> getConfig(String lang) async {
    var response = await http
        .get(Uri.parse("https://salvavidas.mundoultra.com/config.json"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      beta = data["beta"];
      signInRequired = data["signInRequired"];
      mailAlwaysInSpanish = data["mailAlwaysInSpanish"];
      if (Platform.isIOS) {
        betaMessage = data["betaMessage-$lang-ios"];
      } else {
        betaMessage = data["betaMessage-$lang"];
      }
    }
  }

  Future<bool> canShowNotification() async {
    var sp = await SharedPreferences.getInstance();

    if (sp.containsKey(_showedNotification)) {
      var value = sp.getBool(_showedNotification);
      if (value != null) {
        return !value;
      }
    }
    sp.setBool(_showedNotification, true);
    return true;
  }
}
