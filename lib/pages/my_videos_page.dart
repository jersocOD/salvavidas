import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:report_child/classes/child_case.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/pages/view_sent_case_page.dart';
import 'package:report_child/widgets/status_flag.dart';
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

  RefreshController _refreshController = RefreshController();

  void _onRefresh() async {
    // monitor network fetch
    childCases = await CaseUploader().getCases(context);
    setState(() {});
    print("Refreshing.....");
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    childCases = await CaseUploader().getCases(context);
    print("Loading.....");
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: false,
      header: Platform.isIOS
          ? ClassicHeader(
              releaseText: translate('MyVideosPage.Loading.Refresh'),
              refreshingText: translate('MyVideosPage.Loading.Loading'),
              completeText: translate('MyVideosPage.Loading.Updated'),
            )
          : MaterialClassicHeader(
              offset: -20,
            ),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemBuilder: (c, index) => _childCaseCard(childCases[index]),
        itemCount: childCases.length,
      ), /* Column(
        children: List.generate(
            childCases.length, (index) => _childCaseCard(childCases[index])),
      ), */
    );
  }

  Widget _childCaseCard(QueryDocumentSnapshot<ChildCase> childCase) {
    String locationRef = childCase.data().referencia;

    if (childCase.data().placemark != "") {
      var placemark = jsonDecode(childCase.data().placemark);
      locationRef = placemark["locality"];
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  ViewSentCasePage(childCaseSnapshot: childCase)));
        },
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(const Radius.circular(10.0)),
          ),
          elevation: 8,
          child: Stack(
            alignment: AlignmentDirectional.bottomEnd,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          locationRef,
                          style: TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          childCase.data().observacion,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 15.0, bottom: 45.0, right: 15.0),
                  child: StatusFlag(status: childCase.data().status),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
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
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
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
