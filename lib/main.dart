import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:report_child/controllers/translate_pref.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/models/case_model.dart';
import 'package:report_child/pages/home_page.dart';
import 'package:report_child/pages/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'controllers/bottom_nav_controller.dart';
import 'package:flutter_translate/flutter_translate.dart';

void main() async {
  // Fetch the available cameras before initializing the app.
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'es',
    supportedLocales: ['en_US', 'es'],
    preferences: TranslatePreferences(),
  );
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountModel()),
        ChangeNotifierProvider(create: (_) => CaseModel()),
      ],
      child: LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: MaterialApp(
          title: 'Salvavidas',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          supportedLocales: localizationDelegate.supportedLocales,
          locale: localizationDelegate.currentLocale,
          home: SignInScreen(),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            localizationDelegate
          ],
        ),
      ),
    );
  }
}
