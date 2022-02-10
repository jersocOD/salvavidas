import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
      return translate('ChildCase.Status.InProgress');
    } else if (status == "Attended")
      return translate('ChildCase.Status.Attended');
    return translate('ChildCase.Status.InReview');
  }

  Color _getColorFromStatus(String status) {
    if (status == "In Progress") {
      return Colors.orangeAccent;
    } else if (status == "Attended") return Colors.greenAccent;
    return Colors.redAccent;
  }
}
