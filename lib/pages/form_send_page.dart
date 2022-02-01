import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/styles/colors.dart';
import 'package:report_child/styles/text_styles.dart';
import 'package:video_player/video_player.dart';

class FormSendPage extends StatefulWidget {
  @override
  _FormSendPageState createState() => _FormSendPageState();
}

class _FormSendPageState extends State<FormSendPage> {
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  @override
  void initState() {
    super.initState();

    _startVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Last Step", style: Styles.appBarTitleStyle),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _thumbnailWidget(),
          SizedBox(
            height: 30,
            width: double.infinity,
          ),
          _Form()
        ],
      ),
    );
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;

    return localVideoController == null
        ? Padding(
            padding: const EdgeInsets.only(top: 60),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                CustomColors.firebaseOrange,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(3.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3.0),
                child: Container(
                  child: AspectRatio(
                      aspectRatio: localVideoController.value.size != null
                          ? localVideoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(localVideoController)),
                  decoration: BoxDecoration(
                      /* border: Border.all(color: Colors.pink) */),
                  height: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
  }

  Future<void> _startVideoPlayer() async {
    var cs = Provider.of<CaseModel>(context, listen: false);
    if (cs.videoBytes == null || cs.videoPath == null) return;
    CaseUploader().saveCase(context);
    final VideoPlayerController vController =
        VideoPlayerController.file(File(cs.videoPath!));

    videoPlayerListener = () {
      if (videoController != null && videoController!.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        videoController = vController;
      });
    }
    await vController.play();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(3.0),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
        ),
        height: 50,
        child: Column(
          children: [
            Text("ee"),
          ],
        ),
        width: MediaQuery.of(context).size.width - 20,
      ),
    );
  }
}
