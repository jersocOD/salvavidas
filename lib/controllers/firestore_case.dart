import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/controllers/geolocator.dart';
import 'package:report_child/controllers/observaciones_types.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/models/case_model.dart';
import 'config_manager.dart';

class CaseUploader {
  var videos = FirebaseFirestore.instance
      .collection('videos')
      .withConverter<ChildCase>(
        fromFirestore: (snapshot, _) => ChildCase.fromJson(snapshot.data()!),
        toFirestore: (movie, _) => movie.toJson(),
      );

  Future<void> saveCase(BuildContext context) async {
    var cs = Provider.of<CaseModel>(context, listen: false);
    var account = Provider.of<AccountModel>(context, listen: false);
    if (account.user == null) return;
    if (cs.position != null) {
      var placemark = await GeolocalizationManager.setPlacemarkFromCoordinates(
          cs.position!.latitude, cs.position!.longitude);
      if (placemark != null) {
        cs.placemark = json.encode(placemark.toJson());
      }
    }

    // Call the user's CollectionReference to add a new user
    var response = await videos.add(ChildCase(
      userEmail: await _getEmail(account),
      userID: await _getUserID(account),
      authID: account.user!.uid,
      coordinatesLongitude: cs.position!.longitude,
      coordinatesLatitude: cs.position!.latitude,
      videoUrl: "",
      videoThumbnailUrl: "",
      status: "In Progress",
      observacion: cs.observacion,
      referencia: cs.referencia,
      comentarios: cs.comentarios,
      placemark: cs.placemark,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ) /* {
      'user': account.user!.email,
      'coordinatesLongitude': cs.position!.longitude,
      'coordinatesLatitude': cs.position!.latitude,
      'video': "",
      'status':"In Progress",
      'timestamp':DateTime.now().millisecondsSinceEpoch
    } */
        );
    await _uploadVideo(cs.videoBytes!, cs.videoThumbnailBytes, response.id,
        cs.videoPath!, context);
    await videos.doc(response.id).update({
      'videoUrl': "https://salvavidas.mundoultra.com/videos/${response.id}.mp4",
      'videoThumbnailUrl':
          "https://salvavidas.mundoultra.com/thumbnails/${response.id}.jpg"
    });
    await sendMail(
        ["https://salvavidas.mundoultra.com/videos/${response.id}.mp4"],
        cs,
        context);
  }

  static Future<String> _getEmail(AccountModel account) async {
    if (configManager.demoMode) return "unicef@mundoultra.com";

    if (account.user!.email == null) return "";

    return account.user!.email!;
    /* var deviceInfo = DeviceInfoPlugin();

    var iosDeviceInfo = await deviceInfo.iosInfo;
    String? id = iosDeviceInfo.identifierForVendor;
    if (id == null) return account.user!.uid;
    return account.user!.uid + "|" + id; */
  }

  static Future<String> _getUserID(AccountModel account) async {
    var deviceInfo = DeviceInfoPlugin();
    String? id;
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      id = androidDeviceInfo.androidId; // unique ID on Android
    }

    if (id == null)
      return account.user!.uid; // Only if not found, it will use the auth id
    return id;
  }

  static Future<void> sendMail(
      List<String> attachments, CaseModel cs, BuildContext context) async {
    var list = await _getEmailsList();
    Observaciones obs = Observaciones();
    obs.getMapIntl();

    String obsLocalized = obs
        .observacionesIntl[Observaciones.observaciones.indexOf(cs.observacion)];
    var response = await http.post(
        Uri.parse("https://salvavidas.mundoultra.com/send_mail.php"),
        body: {
          "secretKey": "15012022",
          "subject": (configManager.mailAlwaysInSpanish)
              ? "Reporte de Niño ${cs.observacion}"
              : translate("Mail.Subject", args: {"type": obsLocalized}),
          "messageHtml": await messageFromCS(cs, context, obsLocalized),
          if (list["PRIMARY"].isNotEmpty)
            "addresses": jsonEncode(list["PRIMARY"]),
          if (list["CC"].isNotEmpty) "CCaddresses": jsonEncode(list["CC"]),
          if (list["BCC"].isNotEmpty) "CCOaddresses": jsonEncode(list["BCC"]),
          "attachments": jsonEncode(attachments),
        });
    debugPrint("Status Code:" + response.statusCode.toString());
    debugPrint("Body:" + response.body);
  }

  static Future<void> _uploadVideo(
      Uint8List bytesList,
      Uint8List? thumbnailUint8List,
      String id,
      String videoPath,
      BuildContext context) async {
    final String thumbnailBase64;

    if (thumbnailUint8List == null) {
      thumbnailBase64 = "";
    } else {
      thumbnailBase64 = base64Encode(thumbnailUint8List);
    }

    final String videoBase64 = base64Encode(bytesList);

    var response = await http.post(
        Uri.parse("https://salvavidas.mundoultra.com/uploader.php"),
        body: {
          "secretKey": "15012022",
          "videoBytes": videoBase64,
          "thumbnailBytes": thumbnailBase64,
          "id": id,
        });

    debugPrint("Status Code:" + response.statusCode.toString());
    debugPrint("Body:" + response.body);
  }

  Future<List<QueryDocumentSnapshot<ChildCase>>> getCases(
      BuildContext context) async {
    var account = Provider.of<AccountModel>(context, listen: false);
    if (account.user == null) return [];
    /*  updateAllDocuments(account); */
    var queryField = "userEmail";
    var queryValue = await _getEmail(account);

    if (queryValue == "") {
      queryField = "userID";
      queryValue = await _getUserID(account);
      debugPrint("No user email, using userID instead: $queryValue");
      if (queryValue == account.user!.uid) {
        queryField = "authID";
        debugPrint("No user email or userID, using authID instead");
      }
    } else {
      debugPrint("Using user email: $queryValue");
    }
    return await videos
        .where(queryField, isEqualTo: queryValue)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  static Future<Map<String, dynamic>> _getEmailsList() async {
    var response = await http
        .get(Uri.parse("https://salvavidas.mundoultra.com/recipients.json"));

    return jsonDecode(response.body) as Map<String, dynamic>;

/*     return [
      {"name": "Inabif", "email": "webmaster@inabif.gob.pe"},
      {"name": "Unicef", "email": "lima@unicef.org"},
      {
        "name": "Aldeas Infantiles SOS Perú",
        "email": "imagen@aldeasinfantiles.org.pe"
      },
    ]; */
  }

  //Add a new field "userID" to all Firestore documents
/*   static Future<void> updateAllDocuments(AccountModel account) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    var querySnapshot =
        await FirebaseFirestore.instance.collection('videos').get();

    for (var doc in querySnapshot.docs) {
/*       batch.update(doc.reference,
          {'userID': await _getUserID(account), 'authID': account.user!.uid}); */
      String actualEmail = doc.get("userEmail");
      print(actualEmail);
      if (actualEmail.contains("|")) {
        List<String> split = actualEmail.split("|");
        batch.update(doc.reference,
            {'authID': split[0], 'userID': split[1], 'userEmail': ""});
        //"authID|userID"

      }
    }
    return batch.commit();
  } */

  static Future<String> messageFromCS(
      CaseModel cs, BuildContext context, String observacionLocalized) async {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    String lang = configManager.mailAlwaysInSpanish
        ? "es"
        : localizationDelegate.currentLocale.languageCode;
    var response = await http.get(Uri.parse(
        "https://salvavidas.mundoultra.com/mail-templates/$lang.html"));
    String mailData = utf8.decode(response.bodyBytes);

    mailData = mailData.replaceAll("{observacion}", observacionLocalized);
    mailData = mailData.replaceAll("{referencia}", cs.referencia);
    mailData = mailData.replaceAll("{comentarios}", cs.comentarios);
    mailData =
        mailData.replaceAll("{latitude}", cs.position!.latitude.toString());
    mailData =
        mailData.replaceAll("{longitude}", cs.position!.longitude.toString());
    mailData = mailData.replaceAll(
        "{placemark}", getAddressFromPlaceMark(cs.placemark));
    return mailData;
  }

  static String getAddressFromPlaceMark(String json) {
    if (json == "") return "";
    final Map<String, dynamic> placemark = jsonDecode(json);

    String address = "";
    if (placemark["street"] != "") address += placemark["street"] + _coma();
    if (placemark["subLocality"] != "") {
      address += placemark["subLocality"] + _coma();
    }
    if (placemark["locality"] != "" &&
        placemark["locality"] != placemark["name"]) {
      address += placemark["locality"] + _coma();
    }
    if (placemark["name"] != "") address += placemark["name"] + _coma();
    if (placemark["subAdministrativeArea"] != "") {
      address += placemark["subAdministrativeArea"] + _coma();
    }
    if (placemark["administrativeArea"] != "" &&
        placemark["administrativeArea"] != placemark["subAdministrativeArea"]) {
      address += placemark["administrativeArea"] + _coma();
    }
    if (placemark["country"] != "") address += placemark["country"] + _coma();
    if (placemark["postalCode"] != "") address += placemark["postalCode"];

    return address;
  }

  static String _coma() {
    return ", ";
  }
}
