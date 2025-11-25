import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileBody;
  final Widget desktopBody;

  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.desktopBody,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = false;
    try {
      isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    } catch (e) {
      isDesktop = false;
    }

    if (isDesktop) {
      return desktopBody;
    } else {
      return mobileBody;
    }
  }
}
