import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/config_manager.dart';
import 'package:report_child/controllers/permissions_handler.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/pages/account_page.dart';
import 'package:report_child/pages/my_videos_page.dart';
import 'package:report_child/pages/sign_in_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/home_page.dart';
import '../styles/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

final GlobalKey<ScaffoldState> navBarControllerKey = GlobalKey<ScaffoldState>();

class BottomNavController extends StatefulWidget {
  const BottomNavController({Key? key, this.title}) : super(key: key);

  final String? title;
  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _selectedIndex = 0;
  String? title = "Salvavidas";
  static List<Widget> _pages = <Widget>[
    HomePage(),
  ];

  List<BottomNavigationBarItem> _navigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
        icon: const Icon(Icons.videocam),
        label: translate('Pages.Record'),
        tooltip: "Salvavidas"),
    BottomNavigationBarItem(
      icon: const FaIcon(FontAwesomeIcons.child),
      label: translate('Pages.MyVideos'),
      tooltip: translate('Pages.MyVideos'),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.person),
      label: translate('Pages.Account'),
      tooltip: translate('Pages.Account'),
    ),
  ];

  void _onItemTapped(int index) {
/*     if (index != 0) {
      if (disposeCamera != null && !cameraIsDisposed) {
        disposeCamera!();
        /*   geolocalizationManager.pauseStreaming(); */
        cameraIsDisposed = true;
      }
    } else {
      if (reinitCamera != null && currentCamera != null && cameraIsDisposed) {
        cameraIsDisposed = false;
        /*  geolocalizationManager.startStreaming(onPositionChanged!); */
        reinitCamera!(currentCamera);
      }
    } */

    setState(() {
      _selectedIndex = index;
      title = _navigationItems[index].tooltip;
    });
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await PermissionsHandler().askPermissions();
      if (Provider.of<AccountModel>(context, listen: false).user == null) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user == null) {
            await Navigator.of(context).pushReplacement(_routeToSignInScreen());
          } else {
            Provider.of<AccountModel>(context, listen: false).user = user;

            _pages = <Widget>[
              HomePage(),
              MyVideosPage(),
              const AccountPage(),
            ];
            setState(() {});
          }
        });
      } else {
        _pages = <Widget>[
          HomePage(),
          MyVideosPage(),
          const AccountPage(),
        ];
        setState(() {});
      }

      var localizationDelegate = LocalizedApp.of(context).delegate;
      await configManager
          .getConfig(localizationDelegate.currentLocale.languageCode);
      /*  if (configManager.demoMode) {
        Provider.of<CaseModel>(context, listen: false).position = Position(
            latitude: -12.07615,
            longitude: -12.07615,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0);
      } */
      if (configManager.beta) {
        if (await configManager.canShowNotification()) {
          // ignore: avoid_single_cascade_in_expression_statements
          AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            dismissOnTouchOutside: false,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    translate('Notification'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Linkify(
                        text: configManager.betaMessage,
                        textAlign: TextAlign.center,
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          } else {
                            throw 'Could not launch $link';
                          }
                        },
                        options: const LinkifyOptions(
                          humanize: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            btnOkOnPress: () {},
          )..show();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _navigationItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
          icon: const Icon(Icons.videocam),
          label: translate('Pages.Record'),
          tooltip: "Salvavidas"),
      BottomNavigationBarItem(
        icon: const FaIcon(FontAwesomeIcons.child),
        label: translate('Pages.MyVideos'),
        tooltip: translate('Pages.MyVideos'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: translate('Pages.Account'),
        tooltip: translate('Pages.Account'),
      ),
    ];
    return Scaffold(
      key: navBarControllerKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title!,
          style: Styles.appBarTitleStyle,
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF6C63FF),
        toolbarHeight: 45,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6C63FF),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        iconSize: 20,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedIconTheme:
            const IconThemeData(color: Color(0xFF6C63FF), size: 25),
        selectedLabelStyle: const TextStyle(
          color: const Color(0xFF6C63FF),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
