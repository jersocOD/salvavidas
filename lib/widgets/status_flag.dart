import 'package:flutter/material.dart';

class StatusFlag extends StatelessWidget {
  final String status;

  const StatusFlag({Key? key, required this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getColorFromStatus(status),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Text(
          _getLabelFromStatus(status),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  String _getLabelFromStatus(String status) {
    if (status == "In Progress") {
      return "En Progreso";
    } else if (status == "Attended") return "Atendido";
    return "Revisándose";
  }

  Color _getColorFromStatus(String status) {
    if (status == "In Progress") {
      return Colors.orangeAccent;
    } else if (status == "Attended") return Colors.greenAccent;
    return Colors.redAccent;
  }
}
