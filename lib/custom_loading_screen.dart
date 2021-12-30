import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:ttp_chat/config.dart';

class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _wLoading();
  }

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
}
