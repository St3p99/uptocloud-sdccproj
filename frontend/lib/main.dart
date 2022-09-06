import 'dart:io';

import 'package:admin/UI/constants.dart';
import 'package:admin/UI/screens/auth/login_screen.dart';
import 'package:admin/UI/screens/auth/signup_screen.dart';
import 'package:admin/UI/screens/main/main_screen.dart';
import 'package:admin/controllers/menu_controller.dart';
import 'package:admin/support/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'UI/behaviors/custom_scroll_behavior.dart';
import 'controllers/user_provider.dart';
import 'service/navigation_service.dart';

void main() {
  if(HTTPS_ENABLED) HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        scrollBehavior: CustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        title: 'UpToCloud',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme:
          GoogleFonts.poppinsTextTheme(Theme
              .of(context)
              .textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        navigatorKey: NavigationService.instance.navigationKey,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          SignupScreen.routeName: (context) => SignupScreen(),
          MainScreen.routeName: (context) => MainScreen(),
        },
        home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MenuController>(
                create: (context) => MenuController(),
              ),
              ChangeNotifierProvider<UserProvider>(
                create: (context) => UserProvider(),
              ),
            ],
            child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Wrapper(userProvider: userProvider);
                })),
    );
  }
}

class Wrapper extends StatefulWidget{

  Wrapper({
  Key? key, required this.userProvider
  }) : super(key: key);

  UserProvider userProvider;

  @override
  _WrapperState createState() => _WrapperState();

}

class _WrapperState extends State<Wrapper> {

  late LoginStatus _status;


  @override
  initState() {
    super.initState();
    widget.userProvider.addListener(_handleUpdateLoginStatus);
    _handleUpdateLoginStatus();
  }

  _handleUpdateLoginStatus(){
    setState(() {
      _status = widget.userProvider.loginStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DEBUG_MODE || _status == LoginStatus.Authenticated?
            MainScreen() :
            LoginScreen();
  }

}
