import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/core/widgets/bh.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isInProgress;
  final double elevation;
  final Color textColor;
  final Color bgColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool isFullWidth;
  final IconData? icon;
  final SvgPicture? svg;
  final bool isDense;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    this.isInProgress = false,
    this.isFullWidth = true,
    this.elevation = 0.0,
    this.textColor = Config.creameryColor,
    this.bgColor = Config.primaryColor,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.svg,
    this.isDense = false,
  }) : super(key: key);

  double get _buttonHeight {
    return isDense ? L.h(30) : L.h(40);
  }

  double get _padHor {
    return isDense ? L.w(0) : L.w(20);
  }

  Color get _borderColor {
    if (isDisabled && !isInProgress) {
      return Config.grayG4Color;
    }

    return borderColor != null ? borderColor! : bgColor;
  }

  double get _borderWidth {
    return borderWidth != null ? borderWidth! : L.v(1);
  }

  Color get _textColor {
    return (isDisabled && !isInProgress) ? Config.grayG2Color : textColor;
  }

  Color get _bgColor {
    return (isDisabled && !isInProgress) ? Config.grayG4Color : bgColor;
  }

  Text get _text {
    if (isDense) {
      return Text(text, style: Ts.b3Bold(_textColor), maxLines: 1);
    }

    return Text(text, style: Ts.b2Bold(_textColor), maxLines: 1);
  }

  ButtonStyle get _buttonStyle {
    return ButtonStyle(
      elevation: MaterialStateProperty.all<double>(elevation),
      backgroundColor: MaterialStateProperty.all<Color>(_bgColor),
      shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(L.v(100)),
          side: BorderSide(width: _borderWidth, color: _borderColor),
        ),
      ),
    );
  }

  Widget _wChild() {
    if (svg != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: _padHor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            svg!,
            const BH(5),
            _text,
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _padHor),
      child: _text,
    );
  }

  Widget _wButton() {
    if (icon != null) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: _buttonHeight,
        child: ElevatedButton.icon(
          style: _buttonStyle,
          label: _wChild(),
          icon: Icon(icon, color: _textColor),
          onPressed: !isDisabled && !isInProgress ? onPressed : null,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _buttonHeight,
      child: ElevatedButton(
        style: _buttonStyle,
        onPressed: !isDisabled && !isInProgress ? onPressed : null,
        child: _wChild(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isInProgress) {
      return Opacity(
        opacity: 0.4,
        child: _wButton(),
      );
    }

    return _wButton();
  }
}
