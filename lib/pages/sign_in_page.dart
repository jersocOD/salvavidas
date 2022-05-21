import 'dart:io';

import 'package:flutter/material.dart';
import 'package:report_child/controllers/authentication.dart';
import 'package:report_child/widgets/anonymous_sign_in_button.dart';
import 'package:report_child/widgets/facebook_sign_in_button.dart';
import 'package:report_child/widgets/logo_title.dart';
import 'package:report_child/widgets/sign_in_button.dart';

import '../styles/colors.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                  child: /* Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ */
                      LogoTitle() /* ],
                ), */
                  ),
              FutureBuilder(
                future: Authentication.initializeFirebase(context: context),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error initializing Firebase');
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: Platform.isAndroid
                          ? [
                              GoogleSignInButton(),
                              FacebookSignInButton(),
                              ContinueSignInButton()
                            ]
                          : [ContinueSignInButton()],
                    );
                  }
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomColors.firebaseOrange,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
