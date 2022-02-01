import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/models/case_model.dart';

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
            status: "In Progress",
            timestamp: DateTime.now()
                .millisecondsSinceEpoch) /* {
      'user': account.user!.email,
      'coordinatesLongitude': cs.position!.longitude,
      'coordinatesLatitude': cs.position!.latitude,
      'video': "",
      'status':"In Progress",
      'timestamp':DateTime.now().millisecondsSinceEpoch
    } */
        );
    await _uploadVideo(cs.videoBytes!, response.id);
    videos.doc(response.id).update({
      'videoUrl': "https://salvavidas.mundoultra.com/videos/${response.id}.mp4"
    });
  }

  static Future<void> _uploadVideo(Uint8List bytesList, String id) async {
    String bytes = base64Encode(bytesList);

    var response = await http.post(
        Uri.parse("https://salvavidas.mundoultra.com/uploader.php"),
        body: {"secretKey": "MAMAMELODY2021", "videoBytes": bytes, "id": id});
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
