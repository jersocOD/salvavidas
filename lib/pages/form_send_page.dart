import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/firestore_case.dart';
import 'package:report_child/controllers/observaciones_types.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/styles/colors.dart';
import 'package:report_child/styles/text_styles.dart';
import 'package:report_child/widgets/video_preview.dart';
import 'package:video_player/video_player.dart';

class FormSendPage extends StatefulWidget {
  @override
  _FormSendPageState createState() => _FormSendPageState();
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

class _FormSendPageState extends State<FormSendPage> {
  final TextEditingController tecReferencia = TextEditingController();
  final TextEditingController tecComentarios = TextEditingController();
  @override
  void initState() {
    super.initState();
    tecReferencia.addListener(() {
      Provider.of<CaseModel>(context, listen: false).referencia =
          tecReferencia.text;
    });
    tecComentarios.addListener(() {
      Provider.of<CaseModel>(context, listen: false).comentarios =
          tecComentarios.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(translate('FormPage.LastStep'),
            style: Styles.appBarTitleStyle),
        backgroundColor: Color(0xFF6C63FF),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            VideoPreview(),
            SizedBox(
              height: 30,
              width: double.infinity,
            ),
            _Form(
              tecComentarios: tecComentarios,
              tecReferencia: tecReferencia,
              sendFunction: () async {
                var cs = Provider.of<CaseModel>(context, listen: false);
                if (cs.videoBytes == null || cs.videoPath == null) return;
                await CaseUploader().saveCase(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    tecComentarios.dispose();
    tecReferencia.dispose();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    Key? key,
    required this.tecReferencia,
    required this.tecComentarios,
    required this.sendFunction,
  }) : super(key: key);
  final TextEditingController tecReferencia;
  final TextEditingController tecComentarios;
  final Function sendFunction;
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
            _ObservacionDropDown(),
            SizedBox(height: 20),
            _CustomTextField(
              tec: tecReferencia,
              title: translate('ChildCase.Reference'),
              placeholder: translate('FormPage.ReferencePlaceholder'),
            ),
            SizedBox(height: 20),
            _CustomTextField(
              tec: tecComentarios,
              title: translate('ChildCase.Comments'),
              placeholder: translate('FormPage.CommentsPlaceholder'),
            ),
            SizedBox(
              height: 10,
              width: double.infinity,
            ),
            _SendButton(sendFunction: sendFunction),
          ],
        ),
        width: MediaQuery.of(context).size.width - 20,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    Key? key,
    required this.tec,
    required this.placeholder,
    required this.title,
  }) : super(key: key);
  final TextEditingController tec;
  final String placeholder;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: Platform.isAndroid
              ? TextField(
                  decoration: InputDecoration(hintText: placeholder),
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  //maxLength: 50,
                  controller: tec,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              : CupertinoTextField(
                  decoration: _kDefaultRoundedBorderDecoration,
                  placeholder: placeholder,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  minLines: 1,
                  //   maxLength: 50,
                  controller: tec,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
        ),
      ],
    );
  }
}

class _SendButton extends StatefulWidget {
  const _SendButton({Key? key, required this.sendFunction}) : super(key: key);
  final Function sendFunction;
  @override
  __SendButtonState createState() => __SendButtonState();
}

class __SendButtonState extends State<_SendButton> {
  bool proccessing = false;
  @override
  Widget build(BuildContext context) {
    return proccessing
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFDF6B)),
            ),
          )
        : ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Color(0xFFFFDF6B),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: () async {
              setState(() {
                proccessing = true;
              });
              await widget.sendFunction();
              setState(() {
                proccessing = false;
              });
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                translate('FormPage.SendVideoButton'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
  }
}

class _ObservacionDropDown extends StatefulWidget {
  @override
  State<_ObservacionDropDown> createState() => _ObservacionDropDownState();
}

class _ObservacionDropDownState extends State<_ObservacionDropDown> {
  Observaciones obs = Observaciones();
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    obs.getMapIntl();
    Widget trailing = Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              obs.observacionesIntl[selectedIndex],
              style: TextStyle(color: Colors.black),
            ),
          )
        : _pickerButton(
            obs.observacionesIntl[selectedIndex], obs.observacionesIntl,
            (value) {
            setState(() {
              selectedIndex = obs.observacionesIntl.indexOf(value);
            });
            Provider.of<CaseModel>(context, listen: false).observacion =
                Observaciones.observaciones[selectedIndex];
          });
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(translate('ChildCase.Type')),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: GestureDetector(
            onTap: Platform.isIOS
                ? () async {
                    await _showPicker(selectedIndex, obs.observacionesIntl,
                        (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    });
                    Provider.of<CaseModel>(context, listen: false).observacion =
                        Observaciones.observaciones[selectedIndex];
                  }
                : null,
            child: Platform.isIOS
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      trailing,
                      Icon(CupertinoIcons.right_chevron,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white70,
                          size: 30),
                    ],
                  )
                : trailing,
          ),
        ),
      ],
    );
  }

  Widget _pickerButton(
      String defaultValue, List<String> values, Function onChanged) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(80, 100)),
      child: DropdownButton<String>(
        isExpanded: true,
        value: defaultValue,
        items: values.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(
              value,
            ),
          );
        }).toList(),
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }

  FixedExtentScrollController fiescPicker = FixedExtentScrollController();
  Future<void> _showPicker(
      int initialIndex, List<String> values, Function onChanged) async {
    fiescPicker = FixedExtentScrollController(initialItem: initialIndex);
    if (Platform.isIOS) {
      await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return CupertinoPicker(
              useMagnifier: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              scrollController: fiescPicker,
              onSelectedItemChanged: (value) {
                onChanged(value);
              },
              itemExtent: 32.0,
              children: values
                  .map(
                    (value) => Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  )
                  .toList(),
            );
          });
    } else {}
  }
}
