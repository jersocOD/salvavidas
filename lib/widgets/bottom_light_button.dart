import 'package:flutter/material.dart';

class BottomLightButton extends StatefulWidget {
  final Function turnOn;
  final Function turnOff;

  const BottomLightButton(
      {Key? key, required this.turnOn, required this.turnOff})
      : super(key: key);
  @override
  _BottomLightButtonState createState() => _BottomLightButtonState();
}

class _BottomLightButtonState extends State<BottomLightButton> {
  bool isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isOn) {
          widget.turnOn();
        } else {
          widget.turnOff();
        }
        setState(() {
          isOn = !isOn;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 50.0, bottom: 40.0),
        child: Icon(isOn ? Icons.flash_on : Icons.flash_off,
            size: 30, color: Colors.white),
      ),
    );
  }
}/* padding: EdgeInsets.all(5.0),
        margin: EdgeInsets.only(bottom: 10.0), */
      
