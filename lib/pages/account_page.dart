import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:report_child/models/account_model.dart';

import 'package:report_child/styles/colors.dart';
import 'package:report_child/widgets/language_drop_down.dart';
import 'package:report_child/widgets/sign_out_button.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late User _user;

  @override
  Widget build(BuildContext context) {
    _user = Provider.of<AccountModel>(context).user!;
    return Scaffold(
      backgroundColor: Color(0XFFD2FDFF), //CustomColors.firebaseNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(),
              _user.photoURL != null
                  ? ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Image.network(
                          _user.photoURL!,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    )
                  : ClipOval(
                      child: Material(
                        color: CustomColors.firebaseGrey.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: CustomColors.firebaseGrey,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 16.0),
              /* Row(
                children: [ */
              Text(
                translate('AccountPage.Hello',
                    args: {"name": _user.displayName!}),
                style: TextStyle(
                  color: Color(0xFF23049D),
                  fontSize: 26,
                ),
              ),
              /*    SizedBox(width: 10.0),
                  Text(
                    _user.displayName!,
                    style: TextStyle(
                      color: CustomColors.firebaseYellow,
                      fontSize: 26,
                    ),
                  ), */
              /* ],
              ), */
              SizedBox(height: 8.0),
              Text(
                '(${_user.email!})',
                style: TextStyle(
                  color: CustomColors.firebaseOrange,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 24.0),
              LanguageDropDown(setState: () {
                setState(() {});
              }),
              SizedBox(height: 24.0),
              Text(
                translate('AccountPage.SignOutPrompt'),
                style: TextStyle(
                  color: Color(0xFF23049D).withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              SignOutButton()
            ],
          ),
        ),
      ),
    );
  }
}
