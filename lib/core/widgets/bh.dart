import 'package:flutter/material.dart';

import 'empty.dart';

class BH extends StatelessWidget {
  final double width;

  const BH(this.width, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: width),
      child: const Empty(),
    );
  }
}
