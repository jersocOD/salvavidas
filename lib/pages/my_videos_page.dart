import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyVideosPage extends StatefulWidget {
  @override
  _MyVideosPageState createState() => _MyVideosPageState();
}

class _MyVideosPageState extends State<MyVideosPage> {
  List<QueryDocumentSnapshot<ChildCase>> childCases = [];
  @override
  void initState() {
    super.initState();
    CaseUploader().getCases(context).then((value) {
      setState(() {
        childCases = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
            childCases.length, (index) => _childCaseCard(childCases[index])),
      ),
    );
  }

  Widget _childCaseCard(QueryDocumentSnapshot<ChildCase> childCase) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        elevation: 8,
        child: Stack(
          children: [
            Column(
              children: [
                ThumbnailAsyncImage(url: childCase.data().videoUrl),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Lat: ${childCase.data().coordinatesLatitude}, Long: ${childCase.data().coordinatesLongitude}",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                decoration: BoxDecoration(
                  color: _getColorFromStatus(childCase.data().status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    _getLabelFromStatus(childCase.data().status),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getColorFromStatus(String status) {
    if (status == "In Progress") {
      return Colors.orangeAccent;
    } else if (status == "Attended") return Colors.greenAccent;
    return Colors.redAccent;
  }
}

String _getLabelFromStatus(String status) {
  if (status == "In Progress") {
    return "En Progreso";
  } else if (status == "Attended") return "Atendido";
  return "Revisándose";
}

class ThumbnailAsyncImage extends StatelessWidget {
  const ThumbnailAsyncImage({Key? key, required this.url}) : super(key: key);
  final String url;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadImage(context),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> image) {
        if (image.hasData) {
          if (image.data != null) {
            return Image.memory(
              image.data!,
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              height: 60,
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<Uint8List?> _loadImage(BuildContext context) async {
    return await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth: MediaQuery.of(context).size.width.truncate(),
      quality: 50,
    );
  }
}
