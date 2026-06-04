import 'package:flutter/material.dart';

class WardSyncLogo extends StatelessWidget {
  final double size;

  const WardSyncLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
    );
  }
}
