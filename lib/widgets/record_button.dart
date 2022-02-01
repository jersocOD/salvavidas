import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  final Function startRecording;
  final Function stopRecording;

  const RecordButton(
      {Key? key, required this.startRecording, required this.stopRecording})
      : super(key: key);
  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isRecording) {
          widget.startRecording();
        } else {
          widget.stopRecording();
        }
        setState(() {
          isRecording = !isRecording;
        });
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        height: 80,
        width: 80,
        padding: EdgeInsets.all(5.0),
        margin: EdgeInsets.only(bottom: 10.0),
        child: !isRecording ? _Record() : _Stop(),
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
