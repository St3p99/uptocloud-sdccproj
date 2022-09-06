import 'package:admin/UI/responsive.dart';
import 'package:admin/controllers/user_provider.dart';
import 'package:admin/support/extensions/string_capitalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';


class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            "assets/icons/menu_profile.svg",
            height: 20, color: Colors.white,
          ),
          if (!Responsive.isMobile(context))
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text(new UserProvider().currentUser!.username.capitalize),
            ),
          // Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}
