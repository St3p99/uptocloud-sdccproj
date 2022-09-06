import 'package:admin/UI/responsive.dart';
import 'package:admin/UI/screens/dashboard/components/profile_card.dart';
import 'package:admin/UI/screens/dashboard/components/search_field.dart';
import 'package:admin/controllers/menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';

class Header extends StatelessWidget {
  Header({
    Key? key,
    required this.title
  }) : super(key: key);

  String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context)) ...[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: context.read<MenuController>().controlMenu,
          ),
          Padding(padding: EdgeInsets.only(left: defaultPadding),),
        ],
        // if (!Responsive.isMobile(context))
        //   Text(
        //     title.capitalize,
        //     style: Theme.of(context).textTheme.headline6,
        //   ),
        // Padding(padding: EdgeInsets.only(left: defaultPadding),),
        if(title == 'home') ...[Expanded(child: SearchField())],
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        ProfileCard()
      ],
    );
  }
}