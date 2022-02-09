import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/controllers/geolocator.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/models/case_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
      userEmail: account.user!.email!,
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
    sendMail(
        ["https://salvavidas.mundoultra.com/videos/${response.id}.mp4"], cs);
  }

  static Future<void> sendMail(List<String> attachments, CaseModel cs) async {
    List<Map<String, String>> addresses = [
      /*  {"name": "Jer1", "email": "jeremyultra@gmail.com"}, */
    ];
    List<Map<String, String>> CCaddresses = [
      /*    {"name": "Jer2", "email": "socratesj.osorio@gmail.com"}, */
    ];
    List<Map<String, String>> CCOaddresses = [
      {"name": "Jer3", "email": "socratesj.osorio@gmail.com"},
    ];
    /*    List<String> attachments = [
     "jeremy.estrella10@gmail.com",
    ]; */

    var response = await http.post(
        Uri.parse("https://salvavidas.mundoultra.com/send_mail.php"),
        body: {
          "secretKey": "MAMAMELODY2021",
          "subject": "Alerta de ${cs.observacion}",
          "message": messageFromCS(cs),
          if (addresses.isNotEmpty) "addresses": jsonEncode(addresses),
          if (CCaddresses.isNotEmpty) "CCaddresses": jsonEncode(CCaddresses),
          if (CCOaddresses.isNotEmpty) "CCOaddresses": jsonEncode(CCOaddresses),
          "attachments": jsonEncode(attachments),
        });
    print("Status Code:" + response.statusCode.toString());
    print("Body:" + response.body);
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
          "secretKey": "MAMAMELODY2021",
          "videoBytes": videoBase64,
          "thumbnailBytes": thumbnailBase64,
          "id": id,
        });

    print("Status Code:" + response.statusCode.toString());
    print("Body:" + response.body);
  }

  Future<List<QueryDocumentSnapshot<ChildCase>>> getCases(
      BuildContext context) async {
    var account = Provider.of<AccountModel>(context, listen: false);
    if (account.user == null) return [];

    return await videos
        .where('userEmail', isEqualTo: account.user!.email)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  static _getEmailInstitutionsList() {
    return [
      {"name": "Inabif", "email": "webmaster@inabif.gob.pe"},
      {"name": "Unicef", "email": "lima@unicef.org"},
      {
        "name": "Aldeas Infantiles SOS Perú",
        "email": "imagen@aldeasinfantiles.org.pe"
      },
    ];
  }

  static messageFromCS(CaseModel cs) {
    return """Saludos<br>

Se ha reportado un niño ${cs.observacion} a través de la aplicación Salvavidas.<br><br>

Estos son los datos:<br><br>

Observación: <strong>${cs.observacion}</strong><br>
Referencia: ${cs.referencia}<br>
Comentarios adicionales: ${cs.comentarios}<br><br>

Estas son sus coordenadas: <br>
Latitud: ${cs.position!.latitude}, Longitud: ${cs.position!.longitude}<br>
Aquí está el mapa a su ubicación: <a href="https://www.google.com/maps/place/${cs.position!.latitude},${cs.position!.longitude}" target="_blank">Ir a Google Maps</a><br>
Esta es su dirección: <strong>${getAddressFromPlaceMark(cs.placemark)}</strong><br><br>

Se le ha adjuntado un <b>video donde se muestra al niño</b>.<br><br>

Atentamente,<br>
Equipo Salvavidas""";
  }

  static String getAddressFromPlaceMark(String json) {
    if (json == "") return "";
    final Map<String, dynamic> placemark = jsonDecode(json);

    String address = "";
    if (placemark["street"] != "") address += placemark["street"] + _coma();
    if (placemark["subLocality"] != "")
      address += placemark["subLocality"] + _coma();
    if (placemark["locality"] != "" &&
        placemark["locality"] != placemark["name"])
      address += placemark["locality"] + _coma();
    if (placemark["name"] != "") address += placemark["name"] + _coma();
    if (placemark["subAdministrativeArea"] != "")
      address += placemark["subAdministrativeArea"] + _coma();
    if (placemark["administrativeArea"] != "" &&
        placemark["administrativeArea"] != placemark["subAdministrativeArea"])
      address += placemark["administrativeArea"] + _coma();
    if (placemark["country"] != "") address += placemark["country"] + _coma();
    if (placemark["postalCode"] != "") address += placemark["postalCode"];

    return address;
  }

  static String _coma() {
    return ", ";
  }
}
