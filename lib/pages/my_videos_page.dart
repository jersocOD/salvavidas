import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:report_child/models/case_model.dart';
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
      if (mounted)
        setState(() {
          childCases = value;
        });
    });
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    childCases = await CaseUploader().getCases(context);
    setState(() {});

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    childCases = await CaseUploader().getCases(context);
    setState(() {});
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(const Radius.circular(10.0)),
        ),
        elevation: 8,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0),
                  ),
                  child: Container(
                      width: double.infinity,
                      child: ThumbnailAsyncImage(
                          videoThumbnailUrl:
                              childCase.data().videoThumbnailUrl)),
                ),
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
              child: Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 45.0, right: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorFromStatus(childCase.data().status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
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
  const ThumbnailAsyncImage({Key? key, required this.videoThumbnailUrl})
      : super(key: key);
  final String videoThumbnailUrl;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      videoThumbnailUrl,
      alignment: Alignment.center,
      fit: BoxFit.fitWidth,
      height: 150,
      loadingBuilder: (_, __, ___) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 150.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 150.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          ),
        );
      },
    ); /* FutureBuilder(
      future: _loadImage(context),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> image) {
        if (image.hasData) {
          if (image.data != null) {
            return Image.memory(
              image.data!,
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              height: 150,
            );
          }
        }
        return Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 150.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          ),
        );
      },
    ); */
  }

/*   Future<Uint8List?> _loadImage(BuildContext context) async {
    return await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxWidth: MediaQuery.of(context).size.width.truncate(),
      quality: 50,
    );
  } */
}
