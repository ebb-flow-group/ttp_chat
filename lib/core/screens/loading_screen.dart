import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

import '../../config.dart';

/// Optional child widget is used in Root
/// where we need to activate "widget.child" in navigator state.
/// For this purpose we render hidden "widget.child".
class LoadingScreen extends StatefulWidget {
  final Widget? child;

  const LoadingScreen({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Widget _wLoading() {
    return SafeArea(
      child: Center(
        child: LoadingBouncingGrid.square(
          backgroundColor: Config.primaryColor,
          size: 100,
          inverted: false,
          duration: const Duration(seconds: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return Stack(
        children: <Widget>[
          Opacity(opacity: 0, child: widget.child),
          _wLoading(),
        ],
      );
    }

    return _wLoading();
  }
}
