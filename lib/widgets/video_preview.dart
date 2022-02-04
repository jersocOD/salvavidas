import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/styles/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final bool isNetwork;
  final String? url;
  VideoPreview({
    this.isNetwork = false,
    this.url,
  });
  @override
  State<VideoPreview> createState() => VideoPreviewState();
}

class VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? videoController;

  VoidCallback? videoPlayerListener;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  @override
  Widget build(BuildContext context) {
    /*  var videoThumbnailBytes =
        Provider.of<CaseModel>(context, listen: false).videoThumbnailBytes; */

    return videoController == null
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
                      aspectRatio: videoController!.value.size != null
                          ? videoController!.value.aspectRatio
                          : 1.0,
                      child: GestureDetector(
                        onTap: () {
                          if (!isPlaying) {
                            videoController!.play();
                          } else {
                            videoController!.pause();
                          }

                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        child: Stack(
                          children: [
                            VideoPlayer(videoController!),
                            Center(
                                child: !isPlaying
                                    ? Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 60,
                                      )
                                    : Icon(
                                        Icons.pause,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 60,
                                      ))
                          ],
                        ),
                      )),
                  decoration: BoxDecoration(
                      /* border: Border.all(color: Colors.pink) */),
                  height: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
            ),
          );
  }

  Future<void> _initVideoPlayer() async {
    late VideoPlayerController vController;
    if (!widget.isNetwork) {
      var cs = Provider.of<CaseModel>(context, listen: false);
      if (cs.videoBytes == null || cs.videoPath == null) return;

      vController = VideoPlayerController.file(File(cs.videoPath!));
    } else {
      vController = VideoPlayerController.network(widget.url!);
    }

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
  }
}
