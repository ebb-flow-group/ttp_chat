import 'package:flutter/material.dart';

import 'empty.dart';

class BR extends StatelessWidget {
  final double height;

  const BR(this.height, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: height),
      child: const Empty(),
    );
  }
}

// SizedBox(height: this.height)
