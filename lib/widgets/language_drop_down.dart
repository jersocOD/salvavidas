import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LanguageDropDown extends StatefulWidget {
  final Function setState;

  const LanguageDropDown({Key? key, required this.setState}) : super(key: key);
  @override
  State<LanguageDropDown> createState() => _LanguageDropDownState();
}

class _LanguageDropDownState extends State<LanguageDropDown> {
  List<String> languages = ["English", "Spanish"];
  List<String> langs = ["en", "es"];
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    languages = [
      translate('Language.name.en'),
      translate('Language.name.es'),
    ];
    var localizationDelegate = LocalizedApp.of(context).delegate;

    selectedIndex =
        langs.indexOf(localizationDelegate.currentLocale.languageCode);
    Widget trailing = Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              languages[selectedIndex],
              style: TextStyle(color: Colors.black),
            ),
          )
        : _pickerButton(languages[selectedIndex], languages, (value) {
            setState(() {
              selectedIndex = languages.indexOf(value);
            });

            changeLocale(context, langs[languages.indexOf(value)]);
            widget.setState();
          });
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(translate('Language.label')),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: GestureDetector(
            onTap: Platform.isIOS
                ? () async {
                    await _showPicker(selectedIndex, languages, (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                      changeLocale(context, langs[value]);
                      widget.setState();
                    });
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
