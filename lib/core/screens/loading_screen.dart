import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/rive_anim.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
          child: RiveAnim(
        riveFileName: 'packages/ttp_chat/assets/anim/loading_anim.riv',
      )),
    );
  }
}
