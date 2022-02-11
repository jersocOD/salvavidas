import 'package:flutter/material.dart';
import 'package:simple_timer/simple_timer.dart';
export 'package:simple_timer/simple_timer.dart';

class VideoTimer extends StatefulWidget {
  final TimerController timerController;
  final Duration duration;
  const VideoTimer(
      {Key? key, required this.timerController, required this.duration})
      : super(key: key);
  @override
  _VideoTimerState createState() => _VideoTimerState();
}

class _VideoTimerState extends State<VideoTimer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: SimpleTimer(
      controller: widget.timerController,
      duration: widget.duration,
      progressTextCountDirection: TimerProgressTextCountDirection.count_up,
      displayProgressIndicator: false,
      progressTextStyle: TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),
    ));
  }
}
