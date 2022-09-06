import 'package:admin/UI/responsive.dart';
import 'package:admin/UI/screens/dashboard/home_screen.dart';
import 'package:admin/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatefulWidget{
  static const routeName = '/main';

  MainScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {
  late SideMenu _sideMenu;
  Widget currentWidget = HomeScreen();

  @override
  initState() {
    super.initState();
    Provider.of<MenuController>(context, listen: false).addListener(_handleUpdateWidget);
    _sideMenu = new SideMenu();
  }

  _handleUpdateWidget(){
    setState(() {
      currentWidget = Provider.of<MenuController>(context, listen: false).currentWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuController>().scaffoldKey,
      drawer: _sideMenu,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: _sideMenu,
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: currentWidget,
            ),
          ],
        ),
      ),
    );
  }

}
