import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:report_child/classes/child_case.dart';
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
    await _uploadVideo(cs.videoBytes!, response.id, cs.videoPath!, context);
    await videos.doc(response.id).update({
      'videoUrl': "https://salvavidas.mundoultra.com/videos/${response.id}.mp4",
      'videoThumbnailUrl':
          "https://salvavidas.mundoultra.com/thumbnails/${response.id}.jpg"
    });
  }

  static Future<void> _uploadVideo(Uint8List bytesList, String id,
      String videoPath, BuildContext context) async {
    final thumbnailUint8List = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: MediaQuery.of(context).size.width.truncate(),
      quality: 50,
    );
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
}
