import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report_child/controllers/permissions_handler.dart';
import 'package:report_child/models/account_model.dart';
import 'package:report_child/pages/account_page.dart';
import 'package:report_child/pages/my_videos_page.dart';
import 'package:report_child/pages/sign_in_page.dart';
import 'package:report_child/widgets/sign_out_button.dart';
import '../pages/home_page.dart';
import '../styles/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final GlobalKey<ScaffoldState> navBarControllerKey = GlobalKey<ScaffoldState>();

class BottomNavController extends StatefulWidget {
  BottomNavController({Key? key, this.title}) : super(key: key);

  final String? title;
  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _selectedIndex = 0;
  String? title = "Help a child";
  static List<Widget> _pages = <Widget>[];

  static const List<BottomNavigationBarItem> _navigationItems =
      <BottomNavigationBarItem>[
    BottomNavigationBarItem(
        icon: Icon(Icons.videocam), label: 'Record', tooltip: 'Help a child'),
    BottomNavigationBarItem(
        icon: FaIcon(FontAwesomeIcons.child),
        label: 'My Videos',
        tooltip: 'My Videos'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person), label: 'Account', tooltip: 'Account'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      title = _navigationItems[index].tooltip;
    });
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
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
              AccountPage(),
            ];
            setState(() {});
          }
        });
      } else {
        _pages = <Widget>[
          HomePage(),
          Text('My Videos', style: Styles.optionStyle),
          AccountPage(),
        ];
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: navBarControllerKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title!,
          style: Styles.appBarTitleStyle,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xFF6C63FF),
        toolbarHeight: 45,
        elevation: 0,
      ),
      body: /* IndexedStack(
        index: _selectedIndex,
        children:  */
          _pages[_selectedIndex],
      /* ), */
      bottomNavigationBar: BottomNavigationBar(
        items: _navigationItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF6C63FF),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        iconSize: 20,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedIconTheme: IconThemeData(color: Color(0xFF6C63FF), size: 25),
        selectedLabelStyle: TextStyle(
          color: Color(0xFF6C63FF),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
