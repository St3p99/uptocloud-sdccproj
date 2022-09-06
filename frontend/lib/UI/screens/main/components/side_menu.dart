import 'package:admin/controllers/user_provider.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/menu_controller.dart';
import '../../../constants.dart';
import '../../../responsive.dart';
import '../../dashboard/home_screen.dart';
import '../../dashboard/search_screen.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              child: InkWell(
                  onTap: () {
                    Provider.of<MenuController>(context, listen: false)
                        .updateWidget(HomeScreen());
                  }, // GO TO HOME
                  child: Image.asset("assets/images/logo.png"))),
          DrawerListTile(
            title: "Home",
            svgSrc: "assets/icons/menu_dashbord.svg",
            press: () {
              Provider.of<MenuController>(context, listen: false)
                  .updateWidget(HomeScreen());
            },
          ),
          DrawerListTile(
            title: "Search",
            svgSrc: "assets/icons/Search.svg",
            press: () {
              Provider.of<MenuController>(context, listen: false)
                  .updateWidget(SearchScreen(
                input: null,
              ));
            },
          ),
          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/logout.svg",
            press: () {
              new UserProvider().logout();
            },
          ),
          DrawerListTile(
            title: "Delete account",
            svgSrc: "assets/icons/delete_account.svg",
            press: () {
              CoolAlert.show(
                  context: context,
                  type: CoolAlertType.confirm,
                  title: "Are you sure you want to delete your account?",
                  text: "Note: This action is irreversible!",
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width * .8
                      : Responsive.isTablet(context)
                          ? MediaQuery.of(context).size.width * .6
                          : MediaQuery.of(context).size.width * .2,
                  backgroundColor: bgColor,
                  confirmBtnColor: primaryColor,
                  onConfirmBtnTap: () {
                    new UserProvider().delete();
                    Navigator.pop(context);
                  });
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        color: Colors.white54,
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
