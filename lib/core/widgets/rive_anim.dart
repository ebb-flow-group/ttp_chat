import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import '../../utils/functions.dart';

class RiveAnim extends StatefulWidget {
  final String? riveFileName;
  final RiveAnimationController? animationController;
  final double height;
  final double width;

  const RiveAnim({
    Key? key,
    this.riveFileName,
    this.animationController,
    this.height = 100,
    this.width = 100,
  }) : super(key: key);

  @override
  _RiveAnimState createState() => _RiveAnimState();
}

class _RiveAnimState extends State<RiveAnim> {
  Artboard? _artBoard;

  void _loadRiveFile() async {
    try {
      var bytes = await rootBundle.load(widget.riveFileName!);
      final file = RiveFile.import(bytes);

      setState(() {
        _artBoard = file.mainArtboard..addController(SimpleAnimation('Main'));
        // widget.animationController!.isActive = true;
      });
    } catch (e) {
      consoleLog('Error loading Rive animation');
    }
  }

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: _artBoard == null ? const SizedBox() : Rive(artboard: _artBoard!),
    );
  }
}
