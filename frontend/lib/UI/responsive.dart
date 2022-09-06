import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop helep us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double metadataDialogHeight(BuildContext context){
      return Responsive.isDesktop(context) ?
          MediaQuery
          .of(context)
          .size
          .height * 0.6
          : Responsive.isTablet(context)
          ? MediaQuery
          .of(context)
          .size
          .height * 0.7
          : MediaQuery
          .of(context)
          .size
          .height * 0.7;
  }

  static double metadataDialogWidth(BuildContext context){
    return  Responsive.isDesktop(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.3
        : Responsive.isTablet(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.4
        : MediaQuery
        .of(context)
        .size
        .width * 0.7;
  }

  static double shareDialogHeight(BuildContext context){
    return Responsive.isDesktop(context) ?
    MediaQuery
        .of(context)
        .size
        .height * 0.6
        : Responsive.isTablet(context)
        ? MediaQuery
        .of(context)
        .size
        .height * 0.6
        : MediaQuery
        .of(context)
        .size
        .height * 0.4;
  }

  static double shareDialogWidth(BuildContext context){
    return Responsive.isDesktop(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.6
        : Responsive.isTablet(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.7
        : MediaQuery
        .of(context)
        .size
        .width * 0.9;
  }

  static double uploadDialogHeight(BuildContext context){
    return Responsive.isDesktop(context) ?
    MediaQuery
        .of(context)
        .size
        .height * 0.6
        : Responsive.isTablet(context)
        ? MediaQuery
        .of(context)
        .size
        .height * 0.7
        : MediaQuery
        .of(context)
        .size
        .height * 0.7;
  }

  static double uploadDialogWidth(BuildContext context){
    return Responsive.isDesktop(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.5
        : Responsive.isTablet(context)
        ? MediaQuery
        .of(context)
        .size
        .width * 0.7
        : MediaQuery
        .of(context)
        .size
        .width * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (_size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (_size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}
