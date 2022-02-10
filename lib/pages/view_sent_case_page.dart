import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:report_child/classes/child_case.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:report_child/models/case_model.dart';

import 'package:report_child/styles/text_styles.dart';
import 'package:report_child/widgets/status_flag.dart';
import 'package:report_child/widgets/video_preview.dart';

class ViewSentCasePage extends StatelessWidget {
  final QueryDocumentSnapshot<ChildCase> childCaseSnapshot;

  const ViewSentCasePage({Key? key, required this.childCaseSnapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = childCaseSnapshot.data();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Reporte", style: Styles.appBarTitleStyle),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            VideoPreview(isNetwork: true, url: data.videoUrl),
            SizedBox(
              height: 30,
              width: double.infinity,
            ),
            _Form(childCase: data),
          ],
        ),
      ),
    );
  }
}

const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: /* Color(0x33000000)*/ Colors.black38,
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);
const BoxDecoration _kDefaultRoundedBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

class _Form extends StatelessWidget {
  const _Form({
    Key? key,
    required this.childCase,
  }) : super(key: key);
  final ChildCase childCase;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(3.0),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StatusFlag(status: childCase.status),
              ],
            ),
            SizedBox(height: 20),
            _CustomTextRow(
              title: translate('ChildCase.Type') + ":",
              text: childCase.observacion,
            ),
            SizedBox(height: 20),
            _CustomTextRow(
              title: translate('ChildCase.Reference') + ":",
              text: childCase.referencia,
            ),
            SizedBox(height: 20),
            _CustomTextRow(
              title: translate('ChildCase.Comments') + ":",
              text: childCase.comentarios,
            ),
            SizedBox(
              height: 10,
              width: double.infinity,
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width - 20,
      ),
    );
  }
}

class _CustomTextRow extends StatelessWidget {
  const _CustomTextRow({
    Key? key,
    required this.text,
    required this.title,
  }) : super(key: key);

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title)),
        SizedBox(
          width: 15,
        ),
        Expanded(
            child: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 15),
        )),
      ],
    );
  }
}
