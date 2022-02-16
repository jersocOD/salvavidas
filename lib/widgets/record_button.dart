import 'package:flutter/material.dart';
import 'package:report_child/controllers/config_manager.dart';

class RecordButton extends StatefulWidget {
  final Function startRecording;
  final Function stopRecording;
  final Function record;

  const RecordButton(
      {Key? key,
      required this.startRecording,
      required this.stopRecording,
      required this.record})
      : super(key: key);
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;
  bool isPressing = false;

  void changeState() {
/*     if (!isRecording) {
      widget.startRecording();
    } else {
      widget.stopRecording();
    } */

    widget.record();
/*     setState(() {
      isRecording = !isRecording;
    }); */
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        changeState();
      },
      onLongPressStart: (details) {
        isPressing = true;
        setState(() {});
      },
      onLongPressEnd: (details) {
        isPressing = false;
        setState(() {});
        changeState();
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        height: 80,
        width: 80,
        padding: EdgeInsets.all(5.0),
        margin: EdgeInsets.only(bottom: 10.0),
        child: !isRecording
            ? _Record(opacity: isPressing ? 0.7 : 1.0)
            : _Stop(opacity: isPressing ? 0.7 : 1.0),
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({Key? key, this.opacity = 1.0}) : super(key: key);
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({Key? key, this.opacity = 1.0}) : super(key: key);
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(opacity),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
